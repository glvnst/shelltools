#!/usr/bin/env python
"""
fexclude: print arguments to the system "find" utility that exclude and prune
the given arguments
"""
import argparse
import sys


def main():
    """
    primary function for command-line execution. return an exit status integer
    or a bool type (where True indicates successful exection)
    """
    argp = argparse.ArgumentParser(description=(
        "print arguments to the system 'find' utility that exclude and prune "
        "the given arguments"))
    argp.add_argument('excluded_paths', nargs="+", help=(
        "paths to exclude from the find search"))
    argp.add_argument('-d', '--debug', action="store_true", help=(
        "enable debugging output"))
    args = argp.parse_args()

    exclusions = " -o ".join([
        "-path {}".format(path.replace(" ", "[[:space:]]"))
        for path in args.excluded_paths])
    print "-not ( ( {} ) -prune )".format(exclusions)

    return True


if __name__ == '__main__':
    EXIT_STATUS = main()
    sys.exit(int(not EXIT_STATUS if isinstance(EXIT_STATUS, bool)
                 else EXIT_STATUS))
