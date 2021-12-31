# swupdate

runs software updates on debian-based Linux distributions

## usage

This is the output of the program's interactive help text:

```
Usage: swupdate [-h|--help] [arg [...]]

-h / --help        show this message
-d / --debug       print additional debugging messages
-y / --assume-yes  tell the apt-get system to proceed without prompting

runs a typical software update commands on a debian-based linux system
this includes the following apt-get subcommands:
 * update
 * upgrade
 * autoremove
 * clean
```
