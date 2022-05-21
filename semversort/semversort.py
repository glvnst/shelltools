#!/usr/bin/env python3
import argparse
import functools
import re
import sys
from typing import Any, Final, NamedTuple, Type, TypeVar

T = TypeVar("T", bound="SemVer")


# this program is dumb, you probably want https://pypi.org/project/semver/
# I just had to stick with stdlib for this util... for reasons

SEMVER_REGEX: Final = re.compile(
    # fmt: off
    r"\b"
    r"[RVrv]?"
    r"(?P<major>0|[1-9]\d*)"
    r"\."
    r"(?P<minor>0|[1-9]\d*)"
    r"\."
    r"(?P<patch>0|[1-9]\d*)"
    r"(?:"
        r"-"
        r"(?P<prerelease>"
            r"(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)"
            r"(?:"
                r"\."
                r"(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)"
            r")*"
        r")"
    r")?"
    r"(?:"
        r"\+"
        r"(?P<buildmetadata>"
            r"[0-9a-zA-Z-]+"
            r"(?:\.[0-9a-zA-Z-]+)*"
        r")"
    r")?"
    r"\b"
    # fmt: on
)
SEMVER_MAJOR: Final = "major"
SEMVER_MINOR: Final = "minor"
SEMVER_PATCH: Final = "patch"
SEMVER_PRERELEASE: Final = "prerelease"
SEMVER_BUILDMETADATA: Final = "buildmetadata"


def cmp(a: Any, b: Any) -> int:
    """old-time comparison function does good"""
    return (a > b) - (a < b)


class SemVer(NamedTuple):
    """Container for Semantic Versioning String data"""

    major: int
    minor: int
    patch: int
    prerelease: str
    buildmetadata: str

    @classmethod
    def from_string(cls: Type[T], input_string: str) -> T:
        if match := SEMVER_REGEX.search(input_string):
            matches = match.groupdict()
            return cls(
                int(matches.get(SEMVER_MAJOR, 0)),
                int(matches.get(SEMVER_MINOR, 0)),
                int(matches.get(SEMVER_PATCH, 0)),
                matches.get(SEMVER_PRERELEASE, "") or "",
                matches.get(SEMVER_BUILDMETADATA, "") or "",
            )
        return cls(0, 0, 0, "", "")

    @classmethod
    def semver_cmp(cls: Type[T], a: T, b: T) -> int:
        """
        compare semver a to semver b and return -1 if a<b; 0 if a==b; 1 if a>b
        """
        result = cmp(a.major, b.major)
        if result != 0:
            return result
        result = cmp(a.minor, b.minor)
        if result != 0:
            return result
        result = cmp(a.patch, b.patch)
        if result != 0:
            return result

        # comments from https://semver.org/
        # When major, minor, and patch are equal, a pre-release version has
        # lower precedence than a normal version:
        # Example: 1.0.0-alpha < 1.0.0
        result = cmp(len(a.prerelease) == 0, len(b.prerelease) == 0)
        if result != 0:
            return result

        # Precedence for two pre-release versions with the same major, minor,
        # and patch version MUST be determined by comparing each dot separated
        # identifier from left to right until a difference is found as follows:
        #
        # Identifiers consisting of only digits are compared numerically.
        #
        # Identifiers with letters or hyphens are compared lexically in ASCII
        # sort order.
        #
        # Numeric identifiers always have lower precedence than non-numeric
        # identifiers.
        #
        # A larger set of pre-release fields has a higher precedence than a
        # smaller set, if all of the preceding identifiers are equal.
        #
        # Example:
        # 1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta
        #  < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0.
        a_ids = a.prerelease.split(".")
        b_ids = b.prerelease.split(".")
        while True:
            try:
                aid = a_ids.pop(0)
            except IndexError:
                return -1 if b_ids else 0
            try:
                bid = b_ids.pop(0)
            except IndexError:
                return 1
            if aid.isnumeric() and bid.isnumeric():
                result = cmp(int(aid), int(bid))
                if result != 0:
                    return result
                continue
            result = cmp(aid, bid)
            if result != 0:
                return result

        # buildmetadata is not factored into semver comparisons by design

        return 0


def semver_str_cmp(a_string: str, b_string: str) -> int:
    return SemVer.semver_cmp(
        SemVer.from_string(a_string),
        SemVer.from_string(b_string),
    )


def main() -> int:
    """
    entrypoint for direct execution; returns an integer suitable for use with sys.exit
    """
    argp = argparse.ArgumentParser(
        description=("utility for sorting input lines by semver number")
    )
    argp.add_argument(
        "--debug",
        action="store_true",
        help="enable debug output",
    )
    argp.add_argument(
        "input",
        type=argparse.FileType("rt", encoding="utf-8"),
        default=[sys.stdin],
        nargs="*",
        help="file(s) whose lines should be read, sorted, and printed",
    )
    args = argp.parse_args()

    semver_keyfunc = functools.cmp_to_key(semver_str_cmp)

    for file in args.input:
        for line in sorted(file, key=semver_keyfunc):
            print(line, end="")

    return 0


if __name__ == "__main__":
    sys.exit(main())
