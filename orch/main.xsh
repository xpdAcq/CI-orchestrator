"""Main CLI entry point for orch"""
import argparse
import os

import yaml
from lazyasd import lazyobject

from orch.conductor import run


@lazyobject
def PARSER():
    p = argparse.ArgumentParser('orch')
    p.add_argument('--rc', default='orch.xsh', dest='rc',
                   help='Orch run control file.')
    p.add_argument('score', help='score yaml file to use for installs')
    return p


def env_main(args=None):
    """The main function that must be called with the orch environment already
    started up.
    """
    ns = PARSER.parse_args(args)
    if os.path.exists(ns.rc):
        source @(ns.rc)
    print($INSTALLERS)
    with open(ns.score, 'r') as f:
        score = yaml.load(f)
    run(score)


def main(args=None):
    """Main function for orch."""
    env_main(args=args)


if __name__ == '__main__':
    main()
