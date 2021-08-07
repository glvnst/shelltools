#!/usr/bin/env python3
""" prints the given data with quoted-printable encoding removed """
import argparse
import quopri
import sys


def qpdecoded(
    input_bytes: bytes, encoding: str = "iso-8859-1", header: bool = False
) -> str:
    """
    decode the given input string and write the result to STDOUT
    """
    return quopri.decodestring(input_bytes, header=header).decode(encoding)


def main() -> int:
    """
    entry point for command-line execution; return value suitable for use with sys.exit
    """
    argp = argparse.ArgumentParser(
        description="This command performs MIME quoted-printable transport decoding"
    )
    argp.add_argument(
        "file",
        type=argparse.FileType("rb"),
        nargs="+",
        help="a file path which should be read and decoded to the standard out",
    )
    argp.add_argument(
        "-e",
        "--encoding",
        default="iso-8859-1",
        help="specify the encoding of the input file(s)",
    )
    argp.add_argument(
        "--header",
        "--qencoded",
        action="store_true",
        help="treat the input as a Q-encoded header (RFC 1522, Part Two) wherein underscore maps to space",
    )
    args = argp.parse_args()

    for filehandle in args.file:
        input_data = filehandle.read()
        decoded_data = qpdecoded(input_data, encoding=args.encoding, header=args.header)
        sys.stdout.write(decoded_data + "\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())
