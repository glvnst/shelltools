#!/usr/bin/python
""" Print a random value using the specified parameters """
import argparse
import random
import sys

if __name__ == "__main__":
    ARGP = argparse.ArgumentParser(description=("Print a random value using "
        "the specified parameters"))
    ARGP.add_argument("low", type=int,
        help="the lower boundary for the allowable range")
    ARGP.add_argument("high", type=int,
        help="the upper boundary for the allowable range")
    ARGP.add_argument("-c", "--count", type=int, default=1,
        help="the number of random values to print")
    ARGS = ARGP.parse_args()

    if ARGS.low >= ARGS.high:
        sys.stderr.write("Invalid range specified: {}-{}\n".format(ARGS.low,
                                                                   ARGS.high))
        sys.exit(1)


    for x in xrange(ARGS.count):
        print random.randrange(start=ARGS.low, stop=ARGS.high)
