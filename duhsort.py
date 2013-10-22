#!/usr/bin/python
""" A tool for sorting the output of the command 'du -h' """
import argparse
import sys

SUFFIXES = {'B': 1,  # Byte
            'K': 1024,  # Kilobyte
            'M': 1048576,  # Megabyte
            'G': 1073741824,  # Gigabyte
            'T': 1099511627776,  # Terabyte
            'P': 1125899906842624}  # Petabyte

if __name__ == "__main__":
    ARGP = argparse.ArgumentParser(
        description="A tool for sorting the output of the command 'du -h'")
    ARGP.add_argument(
        'infile', nargs='*', type=argparse.FileType('r'), default=sys.stdin,
        help=("the input file to read, defaults to stdin if this argument is "
              "omitted"))
    ARGP.add_argument(
        '-r', '--reverse', action='store_true',
        help="print the output lines in reverse order")
    ARGS = ARGP.parse_args()

    PARSED = {}
    for LINE in ARGS.infile:
        SIZE_STRING = LINE.split()[0]
        SIZE = float(SIZE_STRING[0:-1])
        SCALE = SUFFIXES[SIZE_STRING[-1]]
        PARSED[LINE] = SIZE * SCALE

    for LINE in sorted(PARSED, key=PARSED.__getitem__, reverse=ARGS.reverse):
        sys.stdout.write(LINE)
