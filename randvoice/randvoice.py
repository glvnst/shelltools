#!/usr/bin/env python3
""" Print the randomly-chosen name of an available text-to-speech voice """
import argparse
import random
import re
import subprocess  # nosec: B603
import sys
from typing import Any, Callable, Final, List, NamedTuple, Optional, Type, TypeVar

# fmt: off
VOICE_LISTING: Final = re.compile(
    r"^"
    r"(?P<name>[\w\s-]+?)"
    r"\s+"
    r"(?P<locale>[a-z]{2}[_-]\w+)"
    r"\s+#\s+"
    r"(?P<sample>.+)"
    r"$"
)
# fmt: on

NOVELTY_VOICES: Final = (
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
)

T = TypeVar("T", bound="Voice")


class Voice(NamedTuple):
    """
    represents an available TTS voice
    """

    name: str
    locale: str
    lang: str
    cc: str
    sample: str
    novelty: bool

    @classmethod
    def from_groupdict(
        cls: Type[T],
        name: str = "",
        locale: str = "",
        sample: str = "",
    ) -> T:
        lang, cc = re.split(r"[_-]", locale, 1)
        novelty = name in NOVELTY_VOICES
        return cls(
            name=name,
            locale=locale,
            lang=lang,
            cc=cc,
            sample=sample,
            novelty=novelty,
        )

    @classmethod
    def system_list(cls: Type[T]) -> List[T]:
        """
        Return a list of available voices on the system
        """
        cmd: Final = ("/usr/bin/say", "-v", "?")
        voices: List[T] = []
        for line in subprocess.check_output(  # nosec: B603
            cmd,
            encoding="utf-8",
        ).splitlines():
            if match := VOICE_LISTING.match(line):
                voices.append(cls.from_groupdict(**match.groupdict()))
            else:
                print(f"no match: {line}")
        return voices


class Field(NamedTuple):
    """
    simple class which represents fields in a report
    """

    name: str
    width: Optional[int] = None
    transformer: Optional[Callable[[Any], Any]] = None
    label: Optional[str] = None


class Report(NamedTuple):
    """
    simple class for printing reports
    """

    fields: List[Field]
    rows: List[Any]

    def format(self) -> str:
        """
        return the string format for the given fields
        """
        return " ".join(
            [
                f"{{{field.name}:<{field.width}}}"
                if field.width
                else f"{{{field.name}}}"
                for field in self.fields
            ]
        )

    def print(self):
        """
        print the report data
        """
        fmt = self.format()

        # print header
        print(
            fmt.format(
                **{
                    field.name: field.label if field.label else field.name
                    for field in self.fields
                }
            ).rstrip()
        )

        # print delimiter
        print(
            fmt.format(
                **{
                    field.name: "-"
                    * max(
                        (
                            field.width if field.width else 0,
                            len(field.name),
                            len(field.label) if field.label else 0,
                        )
                    )
                    for field in self.fields
                }
            )
        )

        # print rows
        for row in self.rows:
            print(
                fmt.format(
                    **{
                        field.name: field.transformer(row[field.name])
                        if field.transformer
                        else row[field.name]
                        for field in self.fields
                    }
                ).rstrip()
            )


def speak_sample(voice: Voice) -> None:
    """
    speak the sample text in the given Voice using the given voice
    """
    command: Final = ("/usr/bin/say", "-v", voice.name, voice.sample)
    subprocess.check_call(command)  # nosec: B603


def imatch(a: str, b: str) -> bool:
    """
    return True if the given strings are identical (without regard to case)
    """
    return a.lower() == b.lower()


def stderr(message: str):
    """
    writes the given message to stderr
    """
    sys.stderr.write(f"{message}\n")


def main() -> None:
    """entrypoint for command-line execution"""
    argp = argparse.ArgumentParser(
        description=(
            "Print a randomly-chosen name from the system's available "
            "text-to-speech voice"
        )
    )
    argp.add_argument(
        "--include-novelty",
        action="store_true",
        help="exclude the novelty voice set",
    )
    argp.add_argument(
        "--only-novelty",
        action="store_true",
        help="only choose from the novelty voice set",
    )
    argp.add_argument(
        "--speak-sample",
        action="store_true",
        help="speak the sample that corresponds with the selected voice",
    )
    argp.add_argument(
        "--lang",
        help="limit the voice selection to the given language",
    )
    argp.add_argument(
        "--cc",
        help="limit the voice selection to the given country codes",
    )
    argp.add_argument(
        "--list-voices",
        action="store_true",
        help=(
            "instead of printing a random voice, print the list of "
            "(optionally-filtered) voices"
        ),
    )
    argp.add_argument(
        "--verbose",
        action="store_true",
        help="print additional detail",
    )
    args = argp.parse_args()

    voices: List[Voice] = [
        voice
        for voice in Voice.system_list()
        if (
            (
                (not args.cc or imatch(args.cc, voice.cc))
                and (not args.lang or imatch(args.lang, voice.lang))
            )
            and (
                (args.only_novelty and voice.novelty)
                or (
                    not args.only_novelty
                    and (not voice.novelty or args.include_novelty)
                )
            )
        )
    ]

    if not voices:
        stderr("no voices available with given filters")
        sys.exit(1)

    if args.list_voices:
        if args.verbose:
            Report(
                [
                    Field("name", 10, label="voice"),
                    Field("lang", 4),
                    Field("cc", 8),
                    Field("novelty", 7, str),
                    Field("sample", 100),  # actually 96 as of 30-Dec-2021
                ],
                [voice._asdict() for voice in voices],
            ).print()
        else:
            for voice in voices:
                print(f"{voice.name}")
        return

    voice = random.SystemRandom().choice(voices)
    print(voice.name)
    if args.speak_sample:
        if args.verbose:
            stderr(f"sample: {voice.sample}")
        speak_sample(voice)


if __name__ == "__main__":
    main()
