# sumsay

macOS utility for reading checksums aloud

Sometimes it's easier to verify a checksum if it is read aloud to you. That's what this script is for.

## Usage

```
Usage: sumsay [-h|--help] [arg [...]]

-h / --help   show this message
--voice VOICE sets the TTS voice to the given argument. (default: tom)
--list-voices lists the available voices and exit
arg           filename or literal string. if it is a regular file, its
              SHA-256 checksum is calculated and spoken using the macOS
              'say' command. If the arg is not a filename it is assumed
              to be a checksum itself and it is spoken.

```

example:

```sh
$ ./sumsay.sh README.md 
README.md: 8 3 c a d 2 c d 1 c 6 3 6 d 1 2 3 5 8 c 7 1 7 e e 2 0 3 0 7 f a 2 8 b c 1 e 9 5 6 5 8 3 1 6 1 b 6 9 c 6 5 2 6 0 a 0 c 4 9 3 4 2 
```

In this example the utilty reads aloud each letter of the sha256 checksum of the named file. 

It also works with non-file arguments:

```sh
$ ./sumsay.sh 12345
literal checksum: 1 2 3 4 5 
```

In this example the utility reads out each digit, not "twelve thousand three hundred fourty-five"
