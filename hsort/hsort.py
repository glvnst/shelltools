#!/usr/bin/env python3
"""
A tool for sorting text with human-readable byte sizes like "2.5 KiB" or "6TB"
Example uses include sorting the output of "du -h" or "docker image ls".
"""
import argparse
import re
import sys


# byte size multiples are hard. https://en.wikipedia.org/wiki/Kibibyte

# fmt: off
IEC_MULTIPLES = {
    # singular
    'b': 1,
    'B': 1,
    # decimal
    'k':  1000,  # kilobyte
    'kB': 1000,
    'M':  1000000,  # megabyte (1000**2)
    'MB': 1000000,
    'G':  1000000000,  # gigabyte (1000**3)
    'GB': 1000000000,
    'T':  1000000000000,  # terabyte (1000**4)
    'TB': 1000000000000,
    'P':  1000000000000000,  # petabyte (1000**5)
    'PB': 1000000000000000,
    'E':  1000000000000000000,  # exabyte (1000**6)
    'EB': 1000000000000000000,
    'Z':  1000000000000000000000,  # zettabyte (1000**7)
    'ZB': 1000000000000000000000,
    'Y':  1000000000000000000000000,  # yottabyte (1000**8)
    'YB': 1000000000000000000000000,
    # binary
    'Ki':  1024,  # kibibyte
    'KiB': 1024,
    'Mi':  1048576,  # mebibyte (1024**2)
    'MiB': 1048576,
    'Gi':  1073741824,  # gibibyte (1024**3)
    'GiB': 1073741824,
    'Ti':  1099511627776,  # tebibyte (1024**4)
    'TiB': 1099511627776,
    'Pi':  1125899906842624,  # pebibyte (1024**5)
    'PiB': 1125899906842624,
    'Ei':  1152921504606846976,  # exbibyte (1024**6)
    'EiB': 1152921504606846976,
    'Zi':  1180591620717411303424,  # zebibyte (1024**7)
    'ZiB': 1180591620717411303424,
    'Yi':  1208925819614629174706176,  # yobibyte (1024**8)
    'YiB': 1208925819614629174706176,
}

# without these, the default set doesn't recognize "K" nor "KB"
IEC_KILO_PATCH = {
    "K":  1000,  # kilobyte (NOT IEC)
    "KB": 1000,
    "Kb": 1000,
}

# JEDEC / Classic = powers of 1024 with metric labels
CLASSIC_MULTIPLES = {
    'B':  1,
    'K':  1024,  # kilobyte
    'KB': 1024,
    'M':  1048576,  # megabyte (1024^2)
    'MB': 1048576,
    'G':  1073741824,  # gigabyte (1024^3)
    'GB': 1073741824,
    'T':  1099511627776,  # terabyte (1024^4) (not JEDEC)
    'TB': 1099511627776,
    'P':  1125899906842624,  # petabyte (1024^5) (not JEDEC)
    'PB': 1125899906842624,
    'E':  1152921504606846976,  # exabyte (1024^6) (not JEDEC)
    'EB': 1152921504606846976,
    'Z':  1180591620717411303424,  # zettabyte (1024^7) (not JEDEC)
    'ZB': 1180591620717411303424,
    'Y':  1208925819614629174706176,  # yottabyte (1024^8) (not JEDEC)
    'YB': 1208925819614629174706176,
}
# fmt: on


def main():
    """ command-line execution handler """
    argp = argparse.ArgumentParser(
        description="tool for sorting text with human-readable byte sizes like '2.5 KiB' or '6TB'"
    )
    argp.add_argument(
        "infile",
        nargs="*",
        type=argparse.FileType("r"),
        default=sys.stdin,
        help="the input file to read, defaults to stdin if this argument is omitted",
    )
    argp.add_argument(
        "-r",
        "--reverse",
        action="store_true",
        help="print the output lines in reverse order",
    )
    argp.add_argument(
        "-c",
        "--classic",
        action="store_true",
        help="override IEC 1000 byte multiples with JEDEC-ish 1024 byte multiples having metric labels",
    )
    argp.add_argument(
        "-C",
        "--strict-classic",
        action="store_true",
        help="like --classic but also remove support for all IEC 1000 byte multiples",
    )
    argp.add_argument(
        "-s",
        "--strict",
        action="store_true",
        help="do NOT suppliment the supported IEC multiples with unofficial 'K' and 'KB' (1000 bytes values)",
    )
    argp.add_argument(
        "-m",
        "--only-matches",
        action="store_true",
        help="only print lines which contain a recognized data size expression",
    )
    argp.add_argument(
        "-p",
        "--print-sizes",
        action="store_true",
        help="instead of sorting input lines, just print a report of the size multiples that would be used",
    )
    args = argp.parse_args()

    # figure out what byte multiples to use
    multiples = IEC_MULTIPLES

    if not args.strict:
        multiples.update(IEC_KILO_PATCH)

    if args.classic:
        multiples.update(CLASSIC_MULTIPLES)

    if args.strict_classic:
        multiples = CLASSIC_MULTIPLES

    sorted_labels = sorted(multiples.keys(), key=multiples.__getitem__)

    if args.print_sizes:
        sys.stderr.write("LABEL\tBYTES\n")
        for label in sorted_labels:
            sys.stdout.write("{}\t{}\n".format(label, multiples[label]))
        sys.exit(0)

    # build the regex
    # returned match groups look like this: ('98.6', 'MB') or this ('228', 'K')
    # fmt: off
    regex = re.compile(
        (
            r'\b'
            r'(\d+(?:\.\d+)?)'
            r'\s*'
            r'('
        )
        +
        '|'.join(sorted_labels)
        +
        (
            r')'
            r'\b'
        )
    )
    # fmt: on

    # start processing input lines
    parsed = {}
    for line in args.infile:
        match = regex.search(line)
        if not match:
            if not args.only_matches:
                # this just bunches non-matched lines at the beginning
                # I think we can do better, but I don't know how yet
                parsed[line] = 0
            continue

        size_str, multiple_str = match.groups()
        parsed[line] = float(size_str) * multiples[multiple_str]

    for line in sorted(parsed, key=parsed.__getitem__, reverse=args.reverse):
        sys.stdout.write(line)


if __name__ == "__main__":
    main()
