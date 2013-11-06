# Shelltools

Misc tools for use in command shells.

- **conc.sh** : A bash profile include for [managed concurrency in the bash shell](http://galvanist.com/post/51134915590/managed-concurrency-in-the-bash-shell).
- **collect.sh**: A bash profile include for creating a new directory and moving things into it, a little like OS X's "new folder with selection" finder operation.
- **duhsort.py**: A python utility for sorting the output of the command `du -h`. Useful if your sort command doesn't support the `-h` flag.
- **fmt_duration.sh**: A bash shell function that takes a number of seconds and prints it in years, hours, minutes, seconds. Designed for use by other shell functions. Examples of operation:

		$ fmt_duration 35000000
		1 year, 39 days, 20 hours, 13 minutes, 20 seconds

		$ fmt_duration 10
		10 seconds

All files available under a BSD-style license. See LICENSE.txt for complete details.

More coming soon.