#!/usr/bin/python
"""
A tool for sorting text with human-readable byte sizes like "2.5 KiB" or "6TB"
Examples uses include sorting the output of "du -h" or "docker image ls".
"""
import argparse
import re
import sys


# byte size multiples are hard. https://en.wikipedia.org/wiki/Kibibyte
IEC_MULTIPLES = {
    # singular
    'b':   1,
    "B":   1,
    # decimal
    'k':   1000,     # kilobyte
    'kB':  1000,
    'M':   1000**2,  # megabyte
    'MB':  1000**2,
    'G':   1000**3,  # gigabyte
    'GB':  1000**3,
    'T':   1000**4,  # terabyte
    'TB':  1000**4,
    'P':   1000**5,  # petabyte
    'PB':  1000**5,
    'E':   1000**6,  # exabyte
    'EB':  1000**6,
    'Z':   1000**7,  # zettabyte
    'ZB':  1000**7,
    'Y':   1000**8,  # yottabyte
    'YB':  1000**8,
    # binary
    'Ki':  1024,     # kibibyte
    'KiB': 1024,
    'Mi':  1024**2,  # mebibyte
    'MiB': 1024**2,
    'Gi':  1024**3,  # gibibyte
    'GiB': 1024**3,
    'Ti':  1024**4,  # tebibyte
    'TiB': 1024**4,
    'Pi':  1024**5,  # pebibyte
    'PiB': 1024**5,
    'Ei':  1024**6,  # exbibyte
    'EiB': 1024**6,
    'Zi':  1024**7,  # zebibyte
    'ZiB': 1024**7,
    'Yi':  1024**8,  # yobibyte
    'YiB': 1024**8
}

KILO_PATCH = {
    'K':  1000,     # kilobyte (NOT IEC)
    'KB': 1000
}

JEDEC_MULTIPLES = {
    "B":  1,
    'K':  1024,     # kilobyte
    'KB': 1024,
    'M':  1024**2,  # megabyte
    'MB': 1024**2,
    'G':  1024**3,  # gigabyte
    'GB': 1024**3,
    'T':  1024**4,  # terabyte (not JEDEC)
    'TB': 1024**4,
    'P':  1024**5,  # petabyte (not JEDEC)
    'PB': 1024**5,
    'E':  1024**6,  # exbibyte (not JEDEC)
    'EB': 1024**6,
    'Z':  1024**7,  # zebibyte (not JEDEC)
    'ZB': 1024**7,
    'Y':  1024**8,  # yobibyte (not JEDEC)
    'YB': 1024**8
}


# returned match groups look like this:
# ('98.6', 'MB') or this ('228', 'K')
BYTESIZE_REGEXP = re.compile(
    r'\b'
    r'(\d+(?:\.\d+)?)'
    r'\s*'
    r'('
    r'b|B'
    r'|k|kB|K|KB|Ki|KiB'
    r'|M|MB|Mi|MiB'
    r'|G|GB|Gi|GiB'
    r'|T|TB|Ti|TiB'
    r'|P|PB|Pi|PiB'
    r'|E|EB|Ei|EiB'
    r'|Z|ZB|Zi|ZiB'
    r'|Y|YB|Yi|YiB'
    r')'
    r'\b'
)

# no 'K', 'KB' support
STRICT_BYTESIZE_REGEXP = re.compile(
    r'\b'
    r'(\d+(?:\.\d+)?)'
    r'\s*'
    r'('
    r'b|B'
    r'|k|kB|Ki|KiB'
    r'|M|MB|Mi|MiB'
    r'|G|GB|Gi|GiB'
    r'|T|TB|Ti|TiB'
    r'|P|PB|Pi|PiB'
    r'|E|EB|Ei|EiB'
    r'|Z|ZB|Zi|ZiB'
    r'|Y|YB|Yi|YiB'
    r')'
    r'\b'
)


def main():
    """ command-line execution handler """
    argp = argparse.ArgumentParser(
        description="A tool for sorting the output of the command 'du -h'")
    argp.add_argument(
        'infile', nargs='*', type=argparse.FileType('r'), default=sys.stdin,
        help=("the input file to read, defaults to stdin if this argument is "
              "omitted"))
    argp.add_argument(
        '-r', '--reverse', action='store_true',
        help="print the output lines in reverse order")
    argp.add_argument(
        '-t', '--traditional', action='store_true',
        help="override IEC sizes with the 1024 byte JEDEC 100B.01 sizes")
    argp.add_argument(
        '-s', '--strict', action='store_true',
        help=("do not add K and KB as supported 1000 byte size values in the "
              "IEC set"))
    args = argp.parse_args()

    # figure out what byte multiples to use
    multiples = IEC_MULTIPLES
    regex = BYTESIZE_REGEXP

    if args.strict:
        regex = STRICT_BYTESIZE_REGEXP
    else:
        multiples.update(KILO_PATCH)

    if args.traditional:
        regex = BYTESIZE_REGEXP
        multiples.update(JEDEC_MULTIPLES)

    parsed = {}
    for line in args.infile:
        match = regex.search(line)
        if match:
            size_str, multiple_str = match.groups()
            parsed[line] = float(size_str) * multiples[multiple_str]

    for line in sorted(parsed, key=parsed.__getitem__, reverse=args.reverse):
        sys.stdout.write(line)


if __name__ == "__main__":
    main()
