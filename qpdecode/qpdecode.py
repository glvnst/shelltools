#!/usr/bin/env python3
""" prints the given data with quoted-printable encoding removed """
import argparse
import quopri
import sys


def write_decoded(input_string):
    """ decode the given input string and write the result to STDOUT """
    sys.stdout.write(quopri.decodestring(input_string))


def main():
    """ entry point for command-line execution """
    argp = argparse.ArgumentParser(
        description="This command performs MIME quoted-printable transport decoding"
    )
    argp_meg = argp.add_mutually_exclusive_group(required=True)
    argp_meg.add_argument(
        "-f",
        "--file",
        type=argparse.FileType("r"),
        help="a file path which should be read and decoded to the standard out",
    )
    argp_meg.add_argument(
        "-s", "--string", type=str, help="a string to be decoded to standard out"
    )
    args = argp.parse_args()

    input_data = ""
    if args.file:
        for filehandle in args.file:
            input_data = filehandle.read()
    else:
        input_data = args.string

    if input_data:
        write_decoded(input_data + "\n")


if __name__ == "__main__":
    main()
