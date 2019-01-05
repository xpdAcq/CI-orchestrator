#!/usr/bin/env python3
import os
import sys

try:
    from setuptools import setup
    HAVE_SETUPTOOLS = True
except ImportError:
    from distutils.core import setup
    HAVE_SETUPTOOLS = False


def main():
    """The main entry point."""
    if sys.version_info[:2] < (3, 4):
        sys.exit('xonsh currently requires Python 3.4+')
    with open(os.path.join(os.path.dirname(__file__), 'README.rst'), 'r') as f:
        readme = f.read()
    scripts = ['scripts/orch']
    skw = dict(
        name='orch',
        description='Install orchestrator',
        long_description=readme,
        license='BSD',
        version='0.3.1',
        author='Christopher J. Wright',
        maintainer='Christopher J. Wright',
        author_email='cjwright4242@gmail.com',
        url='https://github.com/xpdAcq/CI-orchestrator',
        platforms='Cross Platform',
        classifiers=['Programming Language :: Python :: 3'],
        packages=['orch'],
        package_dir={'orch': 'orch'},
        package_data={'orch': ['*.xsh']},
        scripts=scripts,
        install_requires=['xonsh', 'lazyasd', 'pyyaml', 'xonda'],
        zip_safe=False,
        )
    # WARNING!!! Do not use setuptools 'console_scripts'
    # It validates the depenendcies (of which we have none) everytime the
    # 'orch' command is run. This validation adds ~0.2 sec. to the startup
    # time of xonsh - for every single xonsh run.  This prevents us from
    # reaching the goal of a startup time of < 0.1 sec.  So never ever write
    # the following:
    #
    #     'console_scripts': ['orch = orch.main:main'],
    #
    # END WARNING
    setup(**skw)


if __name__ == '__main__':
    main()
