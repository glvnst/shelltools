# ipsort

utility for sorting the lines in a file by IPv4 addresses they contain

## usage

```
usage: ipsort.py [-h] [--debug] [input ...]

utility for sorting input lines by IPv4 address

positional arguments:
  input       file(s) whose lines should be read, sorted, and printed

optional arguments:
  -h, --help  show this help message and exit
  --debug     enable debug output
```

## examples

typical numeric sorting isn't suitable for IP addresses:

```sh
$ sort -n example.txt
1.1.3.4
1.100.3.4
1.12.3.4
9.8.7.6
10.11.130.14
10.12.13.14
10.9.130.1
19.18.17.16
```

ipsort is capable of this type of sorting:

```sh
$ ipsort example.txt
1.1.3.4
1.12.3.4
1.100.3.4
9.8.7.6
10.9.130.1
10.11.130.14
10.12.13.14
19.18.17.16
```
