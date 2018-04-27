from contextlib import contextmanager
import os


@contextmanager
def indir(d):
    """Context manager for temporarily entering into a directory."""
    old_d = os.getcwd()
    ![cd @(d)]
    yield
    ![cd @(old_d)]


def build_orch(url_stages):
    for url, stage in url_stages:
        git clone @(url)
        with indir(os.path.splitext(url_stages.split('/')[-1])[0]):
            orch @('requirements/{}.yaml'.format(stage))

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
    # run build installs
    sub_run(config['requirements']['build'])

    # do the source install
    @(config['build']['script'])

    # run the run installs
    sub_run(config['requirements']['run'])




def sub_run(config):
    """Run the install

    Parameters
    ----------
    config: dict
        The dictionary of packages to install
    """

    deps = {}
    # Go through the keys in precedence order
    for p in precedence:
        for k, v in config.items():
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
