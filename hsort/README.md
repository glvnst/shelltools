# hsort

tool for sorting text with human-readable byte sizes like "2.5 KiB" or "6TB"


## usage

This is the output of the program's interactive help command:

```
usage: hsort.py [-h] [-r] [-c] [-C] [-s] [-m] [-p] [infile ...]

tool for sorting text with human-readable byte sizes like '2.5 KiB' or '6TB'

positional arguments:
  infile                the input file to read, defaults to stdin if this argument is omitted

optional arguments:
  -h, --help            show this help message and exit
  -r, --reverse         print the output lines in reverse order
  -c, --classic         override IEC 1000 byte multiples with JEDEC-ish 1024 byte multiples having metric labels
  -C, --strict-classic  like --classic but also remove support for all IEC 1000 byte multiples
  -s, --strict          do NOT suppliment the supported IEC multiples with unofficial 'K' and 'KB' (1000 bytes values)
  -m, --only-matches    only print lines which contain a recognized data size expression
  -p, --print-sizes     instead of sorting input lines, just print a report of the size multiples that would be used
```
