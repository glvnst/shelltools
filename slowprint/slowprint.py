#!/usr/bin/env python3
""" shell utility for slowly printing things to the terminal, retro-style """
import argparse
import sys
import time


def slowprint(input_string, delay, output=None):
    """
    slowly write the given input_string to the given output file handle using
    the given delay between each character
    """
    if output is None:
        output = sys.stdout

    write = output.write
    flush = output.flush
    sleep = time.sleep

    # based on https://gist.github.com/gnuton/3c7a46447d2be0aee0b2
    for character in input_string:
        write(character)
        flush()
        sleep(delay)


def main():
    """ entrypoint for command-line execution """
    argp = argparse.ArgumentParser(
        description="shell utility for slowly printing things to the terminal, retro-style",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    argp.add_argument(
        "-d",
        "--delay",
        type=float,
        default=0.02,
        help="inter-character delay in seconds",
    )
    argp.add_argument("strings", nargs="*", help="strings to slow print")
    args = argp.parse_args()

    if not args.strings:
        while True:
            # we could also read a character at a time here... I don't yet have
            # a good reason to do that.
            line = sys.stdin.readline()
            if line == "":
                break
            slowprint(line, args.delay)
        return

    slowprint("\n".join(args.strings) + "\n", args.delay)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.stdout.write("\n")
