#!/usr/bin/python
""" Print the randomly-chosen name of an available text-to-speech voice """
import subprocess
import random
import argparse

NOVELTY_VOICES=set(['Albert', 'Bad News', 'Bahh', 'Bells', 'Boing', 'Bubbles',
'Cellos', 'Deranged', 'Good News', 'Hysterical', 'Pipe Organ', 'Trinoids',
'Whisper', 'Zarvox'])

def get_voice_list():
    """ Return a list of available voices on the system """
    voices = list()
    for line in subprocess.check_output(["say", "-v", "?"]).splitlines():
        words = line.split("  ")
        voices.append(words[0])
    return voices

if __name__ == '__main__':
    ARGP = argparse.ArgumentParser(description=("Print the randomly-chosen "
        "name of an available text-to-speech voice"))
    ARGP.add_argument("-e", "--exclude-novelty-voices", action="store_true",
        help="exclude the novelty voice set")
    ARGP.add_argument("-n", "--only-novelty-voices", action="store_true",
        help="only choose from the novelty voice set")
    ARGS = ARGP.parse_args()

    VOICES = get_voice_list()
    if ARGS.exclude_novelty_voices:
        VOICES=list(set(VOICES) - NOVELTY_VOICES)
    if ARGS.only_novelty_voices:
        VOICES=list(set(VOICES) & NOVELTY_VOICES)

    print random.choice(VOICES)