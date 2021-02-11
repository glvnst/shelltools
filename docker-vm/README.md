# docker-vm

utility for reporting information about the docker desktop virtual machine (including `df`, and `top`)

## Usage

```
Usage: ./docker-vm.sh [-h|--help] command [command_arguments [...]]

"command" is one of the following:

* df - display free disk space in the docker desktop VM
* sh - run POSIX-compliant command interpreter in the docker desktop VM
* top - display sorted information about processes running in the docker desktop VM

Additional arguments are passed to the corresponding command.
```