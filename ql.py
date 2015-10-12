#!/usr/bin/python
""" command-line OS X quicklook tool
Apple's docs on Uniform Type Identifiers can be found on their website at:
http://tinyurl.com/utiref
"""
from __future__ import print_function
import argparse
import subprocess
import os
import sys

SIMPLE_TYPES = {'text': 'public.text',
                'image': 'public.image',
                'movie': 'public.movie',
                'audio': 'public.audio',
                'sound': 'public.audio'}

SPECIAL_NAMES = {'README': 'public.text',
                 'LICENSE': 'public.text',
                 'Makefile': 'public.source-code',
                 'conf': 'public.source-code'}


def warning(*objs):
    """ Write a warning message to stderr """
    print("WARNING:", *objs, file=sys.stderr)


def quicklook(document_list, uniform_type=None):
    """
    Open a quicklook preview of the given documents with the optionally
    specified type
    """
    # reconstruct the list, looking for things that don't exist and giving
    # appropriate warnings
    final_document_list = list()
    for document in document_list:
        if not os.path.exists(document):
            warning('Could not find a file named "{}"'.format(document))
            continue
        final_document_list.append(document)

    if not final_document_list:
        warning("No documents to open")
        return

    command = ['qlmanage']

    if uniform_type:
        command.extend(['-c', uniform_type])

    command.append('-p')
    command.extend(final_document_list)

    with open(os.devnull, 'wb') as devnull:
        subprocess.call(command, stdout=devnull, stderr=subprocess.STDOUT)


if __name__ == "__main__":
    ARGP = argparse.ArgumentParser(description=("command-line interface to "
                                                "quicklook"))
    ARGP.add_argument("documents", type=str, nargs="+",
                      help="the documents to preview")
    ARGP_MEG_TYPE = ARGP.add_mutually_exclusive_group(required=False)
    ARGP_MEG_TYPE.add_argument("-t", "--type", type=str,
                               help=("specifies the simplified type of the "
                                     "given document(s)"))
    ARGP_MEG_TYPE.add_argument("-u", "--uti", type=str,
                               help=("specifies the Uniform Type Identifier "
                                     "of the given document(s)"))
    ARGS = ARGP.parse_args()

    UTI = None

    if ARGS.uti:
        UTI = ARGS.uti
    elif ARGS.type:
        UTI = SIMPLE_TYPES.get(ARGS.type, "public.{}".format(ARGS.type))
    else:
        SPECIAL_DOCS = list(set(SPECIAL_NAMES.keys()) &
                            set([os.path.basename(path)
                                 for path in ARGS.documents]))
        if SPECIAL_DOCS:
            UTI = SPECIAL_NAMES[SPECIAL_DOCS[0]]

    quicklook(ARGS.documents, uniform_type=UTI)
