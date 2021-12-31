# randcron

prints a crontab-style time specification with the hour and minute randomized

## usage

this is the interactive help text from the program:

```sh
usage: randcron.py [-h] [--debug] [--monthday] [--month] [--dayofweek]

prints out a daily cron time spec with random time-of-day

optional arguments:
  -h, --help   show this help message and exit
  --debug      enable debug output (default: False)
  --monthday   choose a random day of the month (1-31) (default: False)
  --month      choose a random month of the year (1-12) (default: False)
  --dayofweek  choose a random day of the week (1-7) (default: False)
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
$ randcron --dayofweek
42 1 * * 3
```