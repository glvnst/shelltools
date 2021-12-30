# backup2usb

thin wrapper for running restic on a macOS system

This utility relies on [restic](https://restic.net) and the [keychain-password shelltool](../keychain-password).

## usage

This is the help test printed by the program:

```
$ backup2usb -h
Usage: backup2usb [-h|--help] [path [...]]

-h / --help   show this message
-d / --debug  print additional debugging messages
path          additional paths to backup

Runs a restic backup of some default paths and any additional paths
```