from contextlib import contextmanager
import os
import shlex


@contextmanager
def indir(d):
    """Context manager for temporarily entering into a directory."""
    old_d = os.getcwd()
    ![cd @(d)]
    yield
    ![cd @(old_d)]


def build_orch(urls):
    for url in urls:
        git clone @(url)
        with indir(os.path.splitext(url.split('/')[-1])[0]):
            orch @('score.yaml')

# Registry of installers
installers = ${...}.get('INSTALLERS',
                        {'conda': 'conda install', 'pip': 'pip install',
                         'orch': build_orch})
# Order to run installers (conda installing pip, then pip installing things)
installer_order = ${...}.get('INSTALLERS_ORDER', ['orch', 'conda', 'pip'])

# Read the precedence configuration (usually from CI)
precedence = ${...}.get('PRECEDENCE', ['default'])
# Bash hack, bash doesn't support array values, so we split strings
# TODO: replace with xonsh environ registry
if isinstance(precedence, str):
    precedence = precedence.split()


def run(config):
    for section in config.get('section_order', ['build', 'install', 'run']):
        sub_run(config[section], section)


def sub_run(config, name):
    """Run the install

    Parameters
    ----------
    config: dict
        The dictionary of packages to install
    """
    if name == 'install':
        @(shlex.split(config))
        return
    deps = {}
    # Go through the keys in precedence order
    for p in precedence:
        for k, v in config.items():
            print(v)
            vg = v.get(p)
            if vg:
                deps[k] = vg

    installs = {}
    for k, v in deps.items():
        installer = list(v.keys())[0]
        if installer in installs:
            installs[installer].append(v[installer])
        else:
            installs[installer] = [v[installer]]

    # execute the installs for each
    for i in installer_order:
        if i in installers and i in installs:
            if isinstance(installers[i], str):
                x = (installers[i] + ' ' + ' '.join(installs[i])).split()
                @(x)
            else:
                installers[i](installs[i])
        elif i not in installers:
            raise KeyError('The {} installer is not currently in the '
                           'installation registry. Please add it by '
                           'updating the $INSTALLERS env var.\n\n '
                           '{}'.format(i, installers))
