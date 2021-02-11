# docker-vol

utility for reporting information about and exploring docker volumes (including `du`)

## Usage

```
Usage: ./docker-vol.sh [-h|--help] command [command_arguments [...]]

"command" is one of the following:

* du - display disk usage statistics for all named volumes on the system
* sh - run POSIX-compliant command interpreter with all named volumes attached

Additional arguments are NOT accepted.
```