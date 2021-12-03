#!/usr/bin/env python3
""" invoke macOS quicklook feature from the command-line """
import argparse
import os
import subprocess
import sys

# Apple's docs on Uniform Type Identifiers can be found on their website at:
# https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259-SW1

SIMPLE_TYPES = {
    "text": "public.plain-text",
    "image": "public.image",
    "movie": "public.movie",
    "audio": "public.audio",
    "sound": "public.audio",
}

SPECIAL_NAMES = {
    "README": "public.plain-text",
    "LICENSE": "public.plain-text",
    "Makefile": "public.source-code",
    "conf": "public.source-code",
}

SPECIAL_EXTENSIONS = {
    ".md": "public.plain-text",
}


def warn(message):
    """Write a warning message to stderr"""
    sys.stderr.write("WARN: {}\n".format(message))


def quicklook(documents, uniform_type=None, debug=False):
    """
    Open a quicklook preview of the given documents with the optionally
    specified type
    """
    # reconstruct the list, looking for things that don't exist and giving
    # appropriate warnings
    filtered_documents = list()
    for document in documents:
        if not os.path.exists(document):
            warn('Could not find a file named "{}"'.format(document))
            continue
        filtered_documents.append(document)
    if not filtered_documents:
        warn("No documents to open")
        return None

    command = ["/usr/bin/qlmanage"]
    if uniform_type:
        command.extend(["-c", uniform_type])
    command.extend(["-p"] + filtered_documents)

    with open(os.devnull, "wb") as devnull:
        if debug:
            stdout = sys.stdout
            stderr = sys.stderr
        else:
            stdout = devnull
            stderr = subprocess.STDOUT
        return subprocess.check_call(command, stdout=stdout, stderr=stderr)


def fileext(filename):
    """return the filename extension for the given filename"""
    parts = os.path.splitext(filename)
    if len(parts) < 2:
        return filename
    return parts[1]


def resolve_types_set(paths):
    """return a set of the computed uniform types for the given paths"""
    types = list()
    for path in paths:
        filename = os.path.basename(path)
        if filename in SPECIAL_NAMES:
            types.append(SPECIAL_NAMES[filename])
            continue
        ext = fileext(filename)
        if ext in SPECIAL_EXTENSIONS:
            types.append(SPECIAL_EXTENSIONS[ext])
            continue
    return set(types)


def main():
    """handler for command-line use"""
    argp = argparse.ArgumentParser(description="command-line quicklook previewer")
    argp.add_argument(
        "-d", "--debug", action="store_true", help="enable qlmanage's console output"
    )
    argp.add_argument(
        "documents", type=str, nargs="+", help="one or more documents to preview"
    )
    # mutually exclusive argument group: -t and -u
    argp_meg_type = argp.add_mutually_exclusive_group(required=False)
    argp_meg_type.add_argument(
        "-t",
        "--type",
        type=str,
        help="specifies the simplified type of the given document(s)",
    )
    argp_meg_type.add_argument(
        "-u",
        "--uniformtype",
        type=str,
        help="specifies the Uniform Type Identifier of the given document(s)",
    )
    args = argp.parse_args()

    uniform_type = None

    if args.uniformtype:
        uniform_type = args.uniformtype
    elif args.type:
        uniform_type = SIMPLE_TYPES.get(args.type, "public." + args.type)
    else:
        # unfortunately qlmanage only accepts a single uniform type code --
        # you can't specify "-c" multiple times.
        #
        # so we try to compute the type of all the files we are given
        # and if there is only one type for the whole bunch -- we use that,
        # otherwise we don't use the computed types at all
        #
        # I considered lanching qlmanage multiple times (once per uniform type)
        # but that UX is terrible, particularly if you make a mistake and give
        # a long list of differently-typed files to preview
        types = resolve_types_set(args.documents)
        if len(types) == 1:
            uniform_type = list(types)[0]

    quicklook(args.documents, uniform_type=uniform_type, debug=args.debug)


if __name__ == "__main__":
    main()
