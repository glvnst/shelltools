# shelltools

Various command-line tools or other scripts.


## Tools

Name | Description
:--- | :----------
[`avg`](avg) | This command-line utility reads lines from the standard input and writes a summary of the numeric data found therein. It was inspired by the pandas ["DataFrame describe"](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.describe.html) method.
[`clear_xquarts_locks`](clear_xquartz_locks) | script deletes any stale lockfiles (often generated by XQuartz crashes)
[`collect`](collect) | combination of mv and mkdir. Creates the given target directory if necessary then moves the given files into the target
[`docker-clean`](docker-clean) | utility removes bits of docker detritus, similar to the standard command 'docker system prune', but with different parameters
[`docker-vm`](docker-vm) | simple utility for reporting information about the docker desktop vm
[`docker-vol`](docker-vol) | simple utility for reporting information about docker
[`fexclude`](fexclude) | print arguments to the system "find" utility that exclude and prune the given arguments
[`fmt_duration`](fmt_duration) | POSIX-shell function which given a number of seconds representing a duration; print that in years, hours, minutes, seconds
[`hsort`](hsort) | tool for sorting text with human-readable byte sizes like "2.5 KiB" or "6TB"
[`k8s-reportall`](k8s-reportall) | Prints a markdown-formatted summary of all the objects in a kubernetes cluster
[`line2null`](line2null) | converts linefeeds on the standard input into null bytes (just calls tr)
[`mdtable`](mdtable) | Utility for working with markdown tables.
[`old`](old) | misc old cruft
[`ql`](ql) | invoke macOS quicklook feature from the command-line
[`qpdecode`](qpdecode) | prints the given data with quoted-printable encoding removed
[`randvoice`](randomvoice) | Print the randomly-chosen name of an available text-to-speech voice
[`randrange`](randrange) | Print a random value using the specified parameters
[`slowprint`](slowprint) | shell utility for slowly printing things to the terminal, retro-style
[`sumsay`](sumsay) | shell function for reading aloud file checksums and keys
[`swupdate`](swupdate) | utility for running software updates on debian-based Linux distributions
[`tev`](tev) | util for reporting characters the terminal is sending
