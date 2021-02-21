# regmv

rename files using regular expressions

this program is different than some regex replacement utilities because the replacement text is specified in the [Python Format Specification Mini-Language](https://docs.python.org/3/library/string.html#format-specification-mini-language), which several useful things loaded in the context, including:

positional params:

    * `0`: `match.group(0)` - "the whole match"

    * `1..n`: `match.group(n)` - the values of the regex capture groups

keyword params:

    * match.groupdict() is unpacked into the keyword params

    * `counter` whose int value is pre-incremented whenever it is accessed (first value = 1)

these params are wrapped so that they have attributes which provide access to common string methods, including:

    * `.capitalize`
    * `.casefold`
    * `.lower`
    * `.lstrip`
    * `.rstrip`
    * `.strip`
    * `.swapcase`
    * `.title`
    * `.upper`
    * `.len`

the arguments can also be sliced and formatted, for example:

    * `{0[2:]}`
    * `{counter:03}`

## Examples

first we'll create some test filenames to work with

```sh
mkdir -p some/things
for n in $(seq 1 11); do
  touch "some/things/test-${n}"
done
```
what that looks like:

```sh
$ find some | sort
some
some/things
some/things/test-1
some/things/test-10
some/things/test-11
some/things/test-2
some/things/test-3
some/things/test-4
some/things/test-5
some/things/test-6
some/things/test-7
some/things/test-8
some/things/test-9
```

let's instead call those files "example":

```sh
$ regmv -s test -r example some/things/*
mv some/things/test-1 some/things/example-1
mv some/things/test-10 some/things/example-10
mv some/things/test-11 some/things/example-11
mv some/things/test-2 some/things/example-2
mv some/things/test-3 some/things/example-3
mv some/things/test-4 some/things/example-4
mv some/things/test-5 some/things/example-5
mv some/things/test-6 some/things/example-6
mv some/things/test-7 some/things/example-7
mv some/things/test-8 some/things/example-8
mv some/things/test-9 some/things/example-9
Perform these operations? (y/N)? >y
```

after confirming, we now have:

```sh
$ find some | sort
some
some/things
some/things/example-1
some/things/example-10
some/things/example-11
some/things/example-2
some/things/example-3
some/things/example-4
some/things/example-5
some/things/example-6
some/things/example-7
some/things/example-8
some/things/example-9
```

lets prepend some zeros to fix the sorting:

```sh
$ regmv -s '(\d+)' -r '{1:02}' some/things/*
mv some/things/example-1 some/things/example-01
mv some/things/example-2 some/things/example-02
mv some/things/example-3 some/things/example-03
mv some/things/example-4 some/things/example-04
mv some/things/example-5 some/things/example-05
mv some/things/example-6 some/things/example-06
mv some/things/example-7 some/things/example-07
mv some/things/example-8 some/things/example-08
mv some/things/example-9 some/things/example-09
Perform these operations? (y/N)? >y
```

Here the `(\d+)` in the search term captures the digits in the filenames and the `{1:02}` is a python string format specification taking that first capture group (the digits) and formatting it so that it is zero-padded to a length of 2 digits.

let's now update our test directory so that the numbers are six digits long and the filenames end in `.txt`:

```sh
$ regmv -s '(\d+)' -r '{1:06}.txt' some/things/*
mv some/things/example-01 some/things/example-000001.txt
mv some/things/example-02 some/things/example-000002.txt
mv some/things/example-03 some/things/example-000003.txt
mv some/things/example-04 some/things/example-000004.txt
mv some/things/example-05 some/things/example-000005.txt
mv some/things/example-06 some/things/example-000006.txt
mv some/things/example-07 some/things/example-000007.txt
mv some/things/example-08 some/things/example-000008.txt
mv some/things/example-09 some/things/example-000009.txt
mv some/things/example-10 some/things/example-000010.txt
mv some/things/example-11 some/things/example-000011.txt
Perform these operations? (y/N)? >y
```

ok, let's just make those numbers 4 digits long and put them at the beginning also lets capitalize the word example and change the dash to an underscore:

```sh
$ regmv -s '(.+)-(\d+)' -r '{2:04}_{1.capitalize}' some/things/*
mv some/things/example-000001.txt some/things/0001_Example.txt
mv some/things/example-000002.txt some/things/0002_Example.txt
mv some/things/example-000003.txt some/things/0003_Example.txt
mv some/things/example-000004.txt some/things/0004_Example.txt
mv some/things/example-000005.txt some/things/0005_Example.txt
mv some/things/example-000006.txt some/things/0006_Example.txt
mv some/things/example-000007.txt some/things/0007_Example.txt
mv some/things/example-000008.txt some/things/0008_Example.txt
mv some/things/example-000009.txt some/things/0009_Example.txt
mv some/things/example-000010.txt some/things/0010_Example.txt
mv some/things/example-000011.txt some/things/0011_Example.txt
Perform these operations? (y/N)? >y
```

the program works fine if there are spaces in the path. currently on macOS, operations that change only the case of a filename require the `-f` flag.

```sh
$ regmv -f -s '_(\w+)' -r '{.upper}' some/th*ings/*
mv 'some/th ings/0001_Example.txt' 'some/th ings/0001_EXAMPLE.txt'
mv 'some/th ings/0002_Example.txt' 'some/th ings/0002_EXAMPLE.txt'
mv 'some/th ings/0003_Example.txt' 'some/th ings/0003_EXAMPLE.txt'
mv 'some/th ings/0004_Example.txt' 'some/th ings/0004_EXAMPLE.txt'
mv 'some/th ings/0005_Example.txt' 'some/th ings/0005_EXAMPLE.txt'
mv 'some/th ings/0006_Example.txt' 'some/th ings/0006_EXAMPLE.txt'
mv 'some/th ings/0007_Example.txt' 'some/th ings/0007_EXAMPLE.txt'
mv 'some/th ings/0008_Example.txt' 'some/th ings/0008_EXAMPLE.txt'
mv 'some/th ings/0009_Example.txt' 'some/th ings/0009_EXAMPLE.txt'
mv 'some/th ings/0010_Example.txt' 'some/th ings/0010_EXAMPLE.txt'
mv 'some/th ings/0011_Example.txt' 'some/th ings/0011_EXAMPLE.txt'
Perform these operations? (y/N)? >y
```


##  Usage

```
usage: regmv [-h] [-d] [-v] [-n] [-f] [-i] [-m MAXREPLACE] -s SEARCH -r REPLACE path [path ...]

use regular expressions to rename files

positional arguments:
  path                  the paths of files to consider for renaming

optional arguments:
  -h, --help            show this help message and exit
  -d, --debug           enable debugging output (default: False)
  -v, --verbose         print a description of all files renamed or skipped (default: False)
  -n, --dry-run         don't actually rename anything, just print what would be renamed (default: False)
  -f, --force           renaming will be performed even if the new filename will overwrite an existing file (default: False)
  -i, --ignorecase      perform case-insensitive matching (default: False)
  -m MAXREPLACE, --maxreplace MAXREPLACE
                        the number of replacements to perform per filename; 0 == replace all instances (default: 0)
  -s SEARCH, --search SEARCH
                        search pattern, a regular expression to apply to each filename (default: None)
  -r REPLACE, --replace REPLACE
                        replacement text, in python string.format-style (default: None)
```

## Support Information

This program is provided without technical support. For more information see the project home page at <https://github.com/glvnst/shelltools/>

## License

This program is distributed WITHOUT ANY WARRANTY under terms described in the file LICENSE.txt at <https://github.com/glvnst/shelltools/>.