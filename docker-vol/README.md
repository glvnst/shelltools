# docker-vol

utility for reporting information about and exploring docker volumes (including `du`)

## Usage

```
Usage: docker-vol [-h|--help] [arg [...]]

-h / --help   show this message
-d / --debug  print additional debugging messages

 du - display disk usage statistics for all named volumes on the system
 ls - display a list of volumes
 sh - run POSIX-compliant command interpreter with all named volumes attached
 load    volname input_tarfile    - load a volume from a tar file
 save    volname [output_tarfile] - save a volume into a tar file
 loaddir volname input_dir        - load a volume from a directory
 savedir volname output_dir       - save a volume into a directory

Docker volume related functions

```