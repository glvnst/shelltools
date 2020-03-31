#!/usr/bin/python

import argparse
import os
import subprocess

# Parse arguments
ap = argparse.ArgumentParser(
    description="Make a directory then move the specified file(s) into it")
ap.add_argument("directory",
               help="The directory to create")
ap.add_argument("file", nargs="+",
               help="The file(s) to move into the newly created directory")
args = ap.parse_args() 

# Sanity check arguments
for filename in args.file:
    if not os.path.exists(filename):
        ap.error("The file \"%s\" was not found" % (filename))

# Make the directory
if subprocess.call(["mkdir", "-p", "--", args.directory]) is 0:
    # Move the stuff into it
    for filename in args.file:
        subprocess.call(["mv", "-i", "--", filename, args.directory])
