from contextlib import contextmanager
import os
import shlex
from xonsh.tools import expand_path


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

url_base = 'http://35.232.222.82/'


def construct_url(*packages, channel='conda-forge'):
    # remove version constraints
    stripped_packages = [p.split('=')[0].split('>')[0].split('<')[0] for p in packages]
    return url_base + channel + '/' + ','.join(stripped_packages)


def meta_conda(packages):
    @((expand_path('conda install' + ' -c ' + construct_url(*packages) + ' ' + ' '.join(packages))).split())

# Registry of installers
installers = ${...}.get('INSTALLERS',
                        {'conda': meta_conda, 'pip': 'pip install',
                         'orch': build_orch, 'cconda': 'conda install'})
# Order to run installers (conda installing pip, then pip installing things)
installer_order = ${...}.get('INSTALLERS_ORDER', ['conda', 'pip', 'orch'])

# Read the precedence configuration (usually from CI)
precedence = ${...}.get('PRECEDENCE', ['default'])
# Bash hack, bash doesn't support array values, so we split strings
# TODO: replace with xonsh environ registry
if isinstance(precedence, str):
    precedence = precedence.split()


def run(config):
    for section in config.get('section_order', ['build', 'install', 'run']):
        print('Operating on section: {}'.format(section))
        sub_run(config[section])


def sub_run(config):
    """Run the install

    Parameters
    ----------
    config: dict
        The dictionary of packages to install
    """
    if isinstance(config, str):
        print('Running {}'.format(config))
        @(shlex.split(config))
        return
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
                x = expand_path((installers[i] + ' ' + ' '.join(installs[i]))).split()
                print('Running {}'.format(x))
                @(x)
            else:
                print('Running {}'.format(installers[i]))
                installers[i](installs[i])
        elif i not in installers:
            raise KeyError('The {} installer is not currently in the '
                           'installation registry. Please add it by '
                           'updating the $INSTALLERS env var.\n\n '
                           '{}'.format(i, installers))
