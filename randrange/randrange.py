#!/usr/bin/env python3
""" Print a random value using the specified parameters """
from __future__ import print_function
import argparse
import random
import sys


def main():
    """ mainly the sole function """
    argp = argparse.ArgumentParser(
        description=(
            "Print a random value using the specified parameters. The low and "
            "high arguments must not be the same. The order of the low and high "
            "arguments is not relevant."
        )
    )
    argp.add_argument(
        "low", type=int, help=("the lower boundary for the allowable range")
    )
    argp.add_argument(
        "high", type=int, help=("the upper boundary for the allowable range")
    )
    argp.add_argument(
        "-c",
        "--count",
        type=int,
        default=1,
        help=("the number of random values to print"),
    )
    args = argp.parse_args()

    if args.low == args.high:
        argp.print_help()
        sys.exit(1)

    low = min(args.low, args.high)
    high = max(args.low, args.high) + 1

    randrange = random.SystemRandom().randrange
    for _ in range(args.count):
        print(randrange(start=low, stop=high))


if __name__ == "__main__":
    main()
