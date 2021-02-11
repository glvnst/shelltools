#!/usr/bin/env python
""" Print the randomly-chosen name of an available text-to-speech voice """
import subprocess
import random
import argparse
import sys


NOVELTY_VOICES = set(
    [
        "Albert",
        "Bad News",
        "Bahh",
        "Bells",
        "Boing",
        "Bubbles",
        "Cellos",
        "Deranged",
        "Good News",
        "Hysterical",
        "Pipe Organ",
        "Trinoids",
        "Whisper",
        "Zarvox",
    ]
)


def get_voice_list():
    """ Return a list of available voices on the system """
    voices = list()
    for line in subprocess.check_output(["say", "-v", "?"]).splitlines():
        words = line.split("  ")
        voices.append(words[0])
    return voices


def main():
    """ entrypoint for command-line execution """
    argp = argparse.ArgumentParser(
        description="Print the randomly-chosen name of an available text-to-speech voice"
    )
    argp.add_argument(
        "-e",
        "--exclude-novelty-voices",
        action="store_true",
        help="exclude the novelty voice set",
    )
    argp.add_argument(
        "-n",
        "--only-novelty-voices",
        action="store_true",
        help="only choose from the novelty voice set",
    )
    args = argp.parse_args()

    voices = set(get_voice_list())
    randchoice = random.SystemRandom().choice

    if args.exclude_novelty_voices:
        voices = voices - NOVELTY_VOICES

    if args.only_novelty_voices:
        # they might not all be there anymore
        voices = voices & NOVELTY_VOICES

    sys.stdout.write(randchoice(list(voices)) + "\n")


if __name__ == "__main__":
    main()
