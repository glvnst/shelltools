#!/usr/bin/env python3
""" prints out a daily cron time spec with random time-of-day """
import argparse
import random
import sys


def main() -> int:
    """
    entrypoint for direct execution; returns an integer suitable for use with sys.exit
    """
    argp = argparse.ArgumentParser(
        description=(
            "prints out a crontab-style time specification with randomized values"
        ),
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    argp.add_argument(
        "--debug",
        action="store_true",
        help="enable debug output",
    )
    argp.add_argument(
        "--monthday",
        action="store_true",
        help="choose a random day of the month (1-31)",
    )
    argp.add_argument(
        "--month",
        action="store_true",
        help="choose a random month of the year (1-12)",
    )
    argp.add_argument(
        "--weekday",
        action="store_true",
        help="choose a random day of the week (1-7)",
    )
    args = argp.parse_args()

    # field         allowed values
    # -----         --------------
    # minute        0-59
    # hour          0-23
    # day of month  1-31
    # month         1-12 (or names, see below)
    # day of week   0-7 (0 or 7 is Sun, or use names)

    rand = random.SystemRandom().randrange
    segments = (
        rand(0, 59),
        rand(0, 23),
        rand(1, 31) if args.monthday else "*",
        rand(1, 12) if args.month else "*",
        rand(1, 7) if args.weekday else "*",
    )
    print(" ".join(str(segment) for segment in segments))

    return 0


if __name__ == "__main__":
    sys.exit(main())
