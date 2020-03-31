#!/usr/bin/python
""" Print a random value using the specified parameters """
from __future__ import print_function
import argparse
import quopri


def main():
    """ mainly the sole function """
    file_reader = argparse.FileType('r')

    argp = argparse.ArgumentParser(description=(
        "This command performs MIME quoted-printable transport decoding"))
    argp_meg1 = argp.add_mutually_exclusive_group(required=True)
    argp_meg1.add_argument("-f", "--file", type=file_reader, nargs="*", help=(
        "one or more file paths which should be read and decoded to standard "
        "out (concatenated in the case of multiple files)"))
    argp_meg1.add_argument("-s", "--string", type=str, nargs="*", help=(
        "one or more strings to be decoded to standard out"))
    args = argp.parse_args()

    input_data = ""
    if args.file:
        for filehandle in args.file:
            input_data += filehandle.read()
    else:
        input_data += args.string

    if input_data:
        decoded = quopri.decodestring(input_data)
        print(decoded)


if __name__ == "__main__":
    main()
