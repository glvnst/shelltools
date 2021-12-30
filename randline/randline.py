#!/usr/bin/env python3
""" utility """
import argparse
import random
import sys
from typing import Callable, Sequence


def randline(filename: str, randchoice: Callable[[Sequence[str]], str]) -> str:
    """
    return a randomly-selected line from the given file
    """
    with open(filename, "rt", encoding="utf-8") as fh:
        return randchoice(fh.readlines()).rstrip()

def main() -> int:
    """
    entrypoint for direct execution; returns an integer suitable for use with sys.exit
    """
    argp = argparse.ArgumentParser(
        description=(""),
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    argp.add_argument(
        "--debug",
        action="store_true",
        help="enable debug output",
    )
    argp.add_argument(
        "file",
        type=str,
        nargs="+",
        help="file from which to print a random line"
    )
    args = argp.parse_args()
    choice = random.SystemRandom().choice

    for filename in args.file:
        print(randline(filename, choice))

    return 0


if __name__ == "__main__":
    sys.exit(main())
