# keychain-password

helper utility for scripts to use for storing and retrieving passwords in the macOS login keychain

Using this script is a better alternative to storing passwords in scripts or in plain files on disk. It is a thin wrapper around the `security find-generic-password` and `security add-generic-password` commands which are part of macOS.

## usage

```
Usage: keychain-password [-h|--help] (get|set) KEYID

-h / --help   show this message
-d / --debug  print additional debugging messages

get KEYID     get the password item with the given KEYID
set KEYID     set the password item with the given KEYID

This utility for getting and setting passwords in the system keychain
```

Setting a value for the key `com.example.myscript`:

```sh
$ keychain-password set com.example.myscript
password data for new item: test
retype password for new item: test
```

In this example the system prompts the user to unlock the system keychain in a dialog box before printing the value for the key `com.example.myscript`:

```sh
$ keychain-password get com.example.myscript
test
```
