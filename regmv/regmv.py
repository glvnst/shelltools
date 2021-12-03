#!/usr/bin/env python3
"""
regmv: use regular expressions to rename files
"""
import argparse
import datetime
import functools
import pathlib
import re
import shlex
import string
import sys
from typing import Callable, Dict, List, Optional, Union


class Counter:
    """implements the counter used in the replacer function"""

    def __init__(self) -> None:
        self.value: int = 0

    def __getattr__(self, name: str) -> int:
        self.value += 1
        return self.value

    def __format__(self, format_spec) -> str:
        self.value += 1
        return self.value.__format__(format_spec)


class StringWrap:
    # pylint: disable=R0903
    """
    wrapper around a string object which provides attribute accessors for
    string methods and constants
    """

    def __init__(self, value: str) -> None:
        """creates a new stringwrap instance"""
        self.value = value

    def __format__(self, format_spec):
        """return a formatted version of self"""
        # print("value:{} format_spec:{}".format(self.value, format_spec))

        # try to pass the __format__ call to the int, float, or regular string
        # representations of self.value
        value = self.value

        if value.isnumeric():
            value = int(value)
        else:
            # maybe its a float?
            try:
                value = float(value)
            except ValueError:
                pass

        return value.__format__(format_spec)

    def __getitem__(self, key):
        if isinstance(key, str):
            if ":" in key:
                # we're possibly getting slices as strings like "0:2" or "1:"
                # this turns them into slice objects
                key = slice(
                    *[
                        (int(split_param) if split_param else None)
                        for split_param in [substr.strip() for substr in key.split(":")]
                    ]
                )
        return self.value.__getitem__(key)

    def __getattr__(self, name: str) -> Union[str, int, object]:
        """call the named string method"""
        constants: Dict[str, str] = {
            "ascii_letters": string.ascii_letters,
            "ascii_lowercase": string.ascii_lowercase,
            "ascii_uppercase": string.ascii_uppercase,
            "digits": string.digits,
            "hexdigits": string.hexdigits,
            "octdigits": string.octdigits,
            "printable": string.printable,
            "punctuation": string.punctuation,
            "whitespace": string.whitespace,
        }
        if (result := constants.get(name)) is not None:
            return StringWrap(result)

        methods: Dict[str, Callable[[str], Union[StringWrap, int]]] = {
            "capitalize": lambda s: StringWrap(s.capitalize()),
            "casefold": lambda s: StringWrap(s.casefold()),
            "lower": lambda s: StringWrap(s.lower()),
            "lstrip": lambda s: StringWrap(s.lstrip()),
            "rstrip": lambda s: StringWrap(s.rstrip()),
            "strip": lambda s: StringWrap(s.strip()),
            "swapcase": lambda s: StringWrap(s.swapcase()),
            "title": lambda s: StringWrap(s.title()),
            "upper": lambda s: StringWrap(s.upper()),
            "len": len,
        }
        if (func := methods.get(name)) is not None:
            return func(self.value)

        raise AttributeError(name)

    def __str__(self):
        return self.value

    def __repr__(self):
        return "StringWrap({})".format(self.value)


class Rename:
    """class representing a rename operation"""

    def __init__(self, path: pathlib.Path, new_name: str) -> None:
        self.old = path
        self.new = path.parent.joinpath(new_name)

    def perform(
        self,
        dry_run: bool = False,
        force: bool = False,
        verbose: bool = False,
    ) -> None:
        """
        rename the file; if the dry_run argument is True, don't actually rename
        anything, just print what would be renamed. if the verbose argument is
        True, print information about the operations being performed
        """
        vprint = functools.partial(cond_print, enable=(verbose or dry_run))
        if force:
            vprint(str(self))
            if not dry_run:
                self.old.replace(self.new)
            return
        # when not forcing we do a .exists check before anything
        if self.new.exists():
            warn("{!s}: destination already exists".format(self))
            return
        vprint(str(self))
        if not dry_run:
            self.old.rename(self.new)

    def __str__(self):
        return "mv {} {}".format(shlex.quote(str(self.old)), shlex.quote(str(self.new)))


def main() -> None:
    """
    direct program entry point
    """
    argp = argparse.ArgumentParser(
        description="use regular expressions to rename files",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    argp.add_argument(
        "-d",
        "--debug",
        action="store_true",
        help="enable debugging output",
    )
    argp.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="print a description of all files renamed or skipped",
    )
    argp.add_argument(
        "-n",
        "--dry-run",
        action="store_true",
        dest="dryrun",
        help="don't actually rename anything, just print what would be renamed",
    )
    argp.add_argument(
        "-f",
        "--force",
        action="store_true",
        help="renaming will be performed even if the new filename will overwrite an existing file",
    )
    argp.add_argument(
        "-i",
        "--ignorecase",
        action="store_true",
        help="perform case-insensitive matching",
    )
    argp.add_argument(
        "-m",
        "--maxreplace",
        type=int,
        default=0,
        help="the number of replacements to perform per filename; 0 == replace all instances",
    )
    argp.add_argument(
        "-s",
        "--search",
        type=str,
        required=True,
        help="search pattern, a regular expression to apply to each filename",
    )
    argp.add_argument(
        "-r",
        "--replace",
        type=str,
        required=True,
        help="replacement text, in python string.format-style",
    )
    argp.add_argument(
        "path",
        nargs="+",
        type=pathlib.Path,
        help="the paths of files to consider for renaming",
    )
    args = argp.parse_args()

    # build up the flags for the search regex
    regex_flags: int = 0
    regex_flags |= re.IGNORECASE if args.ignorecase else 0
    regex_flags |= re.DEBUG if args.debug else 0

    # compile the regex
    search = re.compile(args.search, regex_flags)

    # create a partial wrapper around the replacer function so we can conveniently
    # use it with re.subn
    replace = functools.partial(
        replacer,
        args.replace if not args.replace.startswith("\\-") else args.replace[1:],
        counter=Counter(),
        debug=args.debug,
    )
    vprint = functools.partial(cond_print, enable=args.verbose)

    # the operations list will hold our rename task objects so they can be
    # reviewed by the user before we perform them
    operations: List[Rename] = []

    for path in args.path:
        new_name, match_count = search.subn(replace, path.name, args.maxreplace)
        if not match_count:
            vprint("non-match " + str(path))
            continue
        if new_name == path.name:
            vprint("unchanged " + str(path))
            continue
        operations.append(Rename(path, new_name))

    if not operations:
        print("Nothing to do")
        sys.exit(0)

    if args.dryrun:
        for operation in operations:
            operation.perform(dry_run=True, force=args.force, verbose=args.verbose)
        sys.exit(0)

    # print the list of operations to perform, ask if the user wants to proceed
    print("\n".join([str(op) for op in operations]))
    for _ in range(3):
        response = input("Perform these operations? (y/N)? >").strip().lower()
        if response == "y":
            for operation in operations:
                operation.perform(force=args.force, verbose=args.verbose)
            sys.exit(0)
        elif response in ("n", ""):
            sys.exit(0)
        else:
            print("Invalid response")

    sys.exit(1)


def replacer(
    replace_fmt: str,
    match: re.Match,
    counter: Optional[Counter] = None,
    debug: bool = False,
) -> str:
    """
    this function is given the user's --replace argument, which is passed to
    the python string.format function with several useful things in the
    positional and keyword argument lists, particularly:

    0: match.group(0) - "the whole match"
    1..n: match.group(n) - the values of the regex capture groups

    additionally the match.groupdict is loaded into the keyword arguments
    as well as the keyword "counter", whose int value is pre-incremented
    whenever it is accessed

    these arguments are wrapped so that they have attributes that provide
    access to common string methods, like:

    .capitalize
    .casefold
    .lower
    .lstrip
    .rstrip
    .strip
    .swapcase
    .title
    .upper
    .len

    the arguments can also be sliced and formatted

    this function returns a string which replaces the matched search text
    """
    format_args = (
        StringWrap(match.group(0)),
        *[StringWrap(s) for s in match.groups("")],
    )
    format_kwargs: Dict[str, Union[StringWrap, Counter]] = {
        k: StringWrap(v) for k, v in match.groupdict().items()
    }
    if counter is not None:
        format_kwargs["counter"] = counter

    if debug:
        print(
            "replacer format context; args:{!r}\nkwargs:{!r}".format(
                format_args, format_kwargs
            )
        )

    return replace_fmt.format(
        *format_args,
        **format_kwargs,
    )


def cond_print(output: str, enable: bool = True) -> None:
    """
    print the given output string if "enable" is True
    useful with partials and lambdas
    """
    if not enable:
        return
    print(output)


def warn(message) -> str:
    """
    Print the given message to stderr, with timestamp prepended and newline
    appended, return the message unchanged
    """
    sys.stderr.write("{} {}\n".format(datetime.datetime.now(), message))
    return message


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.stderr.write("\n")
