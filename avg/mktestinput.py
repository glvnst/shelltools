#!/usr/bin/env python3
""" generate a file with a lot of random numbers and words -- to use for testing """
import random
import sys


def load_words(source="/usr/share/dict/words"):
    """
    load words from a dict file and return a list of the contents
    expects one word per line, resulting list is newline-trimmed
    """
    with open(source, "rt") as wordlist:
        return [line.rstrip() for line in wordlist]


def main():
    """entrypoint"""
    rand = random.SystemRandom()
    words = load_words()
    primes = [1, 2, 3, 5, 7]
    maxint = (2 ** 63) - 1

    total_ints = 0
    total_floats = 0

    for _ in range(10000):
        sample_words = [rand.choice(words) for _ in range(rand.randrange(0, 5))]
        sample_floats = [
            rand.random() * rand.choice(primes) for _ in range(rand.randrange(0, 5))
        ]
        sample_ints = [rand.randint(0, maxint) for _ in range(rand.randrange(0, 5))]

        total_floats += sum(sample_floats)
        total_ints += sum(sample_ints)

        line_contents = sample_words + sample_floats + sample_ints
        rand.shuffle(line_contents)
        print(" ".join([str(line) for line in line_contents]))

    total = total_ints + total_floats
    sys.stderr.write(
        "floats: {}\nints: {}\ntotal: {}\n".format(total_floats, total_ints, total)
    )


if __name__ == "__main__":
    main()
