# semversort

utility for sorting the lines in a file by Semantic Versioning strings they contain

## usage

```
usage: semversort.py [-h] [--debug] [input [input ...]]

utility for sorting input lines by semver number

positional arguments:
  input       file(s) whose lines should be read, sorted, and printed

optional arguments:
  -h, --help  show this help message and exit
  --debug     enable debug output
```

## examples

typical numeric sorting isn't suitable for Semantic Versioning strings:

```sh
$ sort -n example.txt

Here are some example lines!
r0.4.1
v0.10.0
v0.3.1
v0.3.2
v0.4.0
v0.5.0
v0.5.1
v0.5.2
v0.6.0
v0.6.1
v0.6.2
v0.6.3
v0.7.0
v0.8.0
v0.8.1
v0.8.2
v0.8.3
v0.8.4
v0.8.5
v0.9.0
v0.9.1
v90.0.1
1.0.0
1.0.0+20130313144700
1.0.0+21AF26D3—-117B344092BD
1.0.0-0.3.7
1.0.0-alpha
1.0.0-alpha
1.0.0-alpha+001
1.0.0-alpha.1
1.0.0-alpha.1
1.0.0-alpha.beta
1.0.0-beta
1.0.0-beta+exp.sha.5114f85
1.0.0-beta.11
1.0.0-beta.2
1.0.0-rc.1
1.0.0-x-y-z.–
1.0.0-x.7.z.92
```

ipsort is capable of this type of sorting:

```sh
$ ./semversort.py example.txt
Here are some example lines!

v0.3.1
v0.3.2
v0.4.0
r0.4.1
v0.5.0
v0.5.1
v0.5.2
v0.6.0
v0.6.1
v0.6.2
v0.6.3
v0.7.0
v0.8.0
v0.8.1
v0.8.2
v0.8.3
v0.8.4
v0.8.5
v0.9.0
v0.9.1
v0.10.0
1.0.0-0.3.7
1.0.0-alpha+001
1.0.0-alpha
1.0.0-alpha
1.0.0-alpha.1
1.0.0-alpha.1
1.0.0-alpha.beta
1.0.0-beta+exp.sha.5114f85
1.0.0-beta
1.0.0-beta.2
1.0.0-beta.11
1.0.0-rc.1
1.0.0-x.7.z.92
1.0.0-x-y-z.–
1.0.0+20130313144700
1.0.0+21AF26D3—-117B344092BD
1.0.0
v90.0.1

```
