#!/usr/bin/env python3
import argparse
import re
import socket
import struct
import sys

IP_REGEX = re.compile(r"\b(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b")


def ip2long(ip):
    """
    Convert an IP string to long
    https://stackoverflow.com/a/9591005
    """
    packedIP = socket.inet_aton(ip)
    return struct.unpack("!L", packedIP)[0]


def ip_key(x):
    """
    returns the sorting key to use for the given value
    """
    match = IP_REGEX.search(x)
    if not match:
        return -1
    return ip2long(match.group(1))


def main() -> int:
    """
    entrypoint for direct execution; returns an integer suitable for use with sys.exit
    """
    argp = argparse.ArgumentParser(
        description=("utility for sorting input lines by IPv4 address")
    )
    argp.add_argument(
        "--debug",
        action="store_true",
        help="enable debug output",
    )
    argp.add_argument(
        "input",
        type=argparse.FileType("rt", encoding="utf-8"),
        default=sys.stdin,
        nargs="*",
        help="file(s) whose lines should be read, sorted, and printed",
    )
    args = argp.parse_args()

    for file in args.input:
        for line in sorted(file, key=ip_key):
            print(line, end="")

    return 0


if __name__ == "__main__":
    sys.exit(main())
