#!/usr/bin/env python3
""" Utility for (re)generating the main README in this repo """
from __future__ import print_function

import argparse
import os
import re
import sys

# fmt: off
README_REGEX = re.compile(
    r'^\s*'
    r'#\s+(?P<title>[^\n]+?)\s*\n'
    r'\n'
    r'(?P<slug>[^\n]{3,}?)'
    r'\s*\n'
    r'.*',
    re.DOTALL)
# fmt: on


def parse_readme(path):
    """
    read the README.md file at the given path and return a tuple of information
    about it (title, slug)
    """
    with open(path, "r") as readme:
        contents = readme.read()

    match = README_REGEX.match(contents)
    if not match:
        raise RuntimeError("Couldn't parse README at {}".format(path))

    return match.groupdict()


def shortpath(path):
    """
    return the given path with only the filename and its parent directory
    e.g. /usr/home/someone/conex/bpython/README.md -> bpython/README.md
    """
    return os.sep.join(path.split(os.sep)[-2:])


def printrow(*fields):
    """
    given a list of fields, print them joined by the markdown table column
    delimiter ' | '
    """
    print(" | ".join(fields))


def print_table(readmes):
    """prints the markdown table of images"""
    headings = [
        "Name",
        "Description",
    ]

    # print the headings
    printrow(*headings)

    # print the dashes below each heading - required for markdown tables
    # explicitly left-aligning by beginning them with :
    printrow(*[":" + ("-" * (len(heading) - 1)) for heading in headings])

    for readme_path in readmes:
        abspath_readme = os.path.abspath(readme_path)

        subdir = abspath_readme.split(os.sep)[-2]
        readme = parse_readme(readme_path)

        printrow(
            # link to subdir with complete readme and container source
            "[`{}`]({})".format(readme["title"], subdir),
            # short description from first non-empty, non-header line of readme
            "{}".format(readme["slug"]),
        )


def print_file(path):
    """open the given file for reading, print it to stdout"""
    with open(path, "r") as pathfh:
        print(pathfh.read())


def main():
    """direct command-line entry-point"""
    argp = argparse.ArgumentParser(
        description=("Utility for (re)generating the main README in this repo"),
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    argp.add_argument(
        "-i",
        "--header",
        action="append",
        help=("header file(s) to include at the beginning of the output"),
    )
    argp.add_argument(
        "readmes", nargs="+", help=("the source README.md files to build from")
    )
    argp.add_argument(
        "-d", "--debug", action="store_true", help=("enable debugging output")
    )
    args = argp.parse_args()

    for header in args.header:
        print_file(header)
    print("## Tools\n")
    print_table(args.readmes)

    return 0


if __name__ == "__main__":
    sys.exit(main())
