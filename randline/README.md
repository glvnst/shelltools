# randline

prints a randomly selected line from the given text file

## usage

This is the help text printed by the program:

```
$ randline.py -h
usage: randline.py [-h] [--debug] file [file ...]

positional arguments:
  file        file from which to print a random line

optional arguments:
  -h, --help  show this help message and exit
  --debug     enable debug output (default: False)

```

Here's an example invocation:

```
$ randline Lessonalyzer.txt
A leopard cannot change its spots without a sci-fi ray or at least some markers.
```