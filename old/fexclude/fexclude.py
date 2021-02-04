#!/usr/bin/env python3
"""
fexclude: print arguments to the system "find" utility that exclude and prune
the given arguments
"""
import argparse
import shlex
from typing import List


def main() -> None:
    """
    print the command-line arguments for excluding a series of paths from a
    find command. for example, given the arguments x, y, and z, the resulting
    output would be:
    -not '(' '(' -path x -or -path y -or -path z ')' -prune ')'
    """
    argp = argparse.ArgumentParser(
        description="print arguments to the system 'find' utility that exclude and prune the given arguments"
    )
    argp.add_argument(
        "exclude", nargs="+", help="paths to exclude from the find search"
    )
    args = argp.parse_args()

    output: List[str] = ["-not", "(", "("]
    for path in sorted(args.exclude):
        output.extend(["-or", "-path", path])
    output.remove("-or")  # the first '-or' is extraneous
    output.extend([")", "-prune", ")"])

    print(shlex.join(output))


if __name__ == "__main__":
    main()
