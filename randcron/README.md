# randcron

prints a crontab-style time specification with randomized values

## usage

this is the interactive help text from the program:

```sh
usage: randcron.py [-h] [--debug] [--monthday] [--month] [--weekday]

prints out a crontab-style time specification with randomized values

optional arguments:
  -h, --help  show this help message and exit
  --debug     enable debug output (default: False)
  --monthday  choose a random day of the month (1-31) (default: False)
  --month     choose a random month of the year (1-12) (default: False)
  --weekday   choose a random day of the week (1-7) (default: False)
```

## example

here are some example invocations:

```sh
$ randcron
41 22 * * *
$ randcron --monthday
40 1 30 * *
$ randcron --monthday --month
53 4 1 5 *
$ randcron --weekday
42 1 * * 3
```