# docker-clean

utility that removes bits of docker detritus, similar to the standard command `docker system prune`, but with different parameters

## Usage

```
Usage: docker-clean.sh [-h | --help]

This utility removes bits of docker detritus, similar to the standard
command 'docker system prune' -- this utility makes some choices about
what to remove:

* Stopped containers older than 4 hours
* Dangling images
* Other images older than 90 days
* Unused networks older than 7 days
* Dangling anonymous volumes (vols w/ 32-character hexadecimal names)

You can override these times by setting the following variables in the
environment (values must be in seconds, current/default values shown):

MAX_AGE_CONTAINER=14400
MAX_AGE_IMAGE=7776000
MAX_AGE_NETWORK=604800

Example command-line invocation using different timing:
$ MAX_AGE_CONTAINER=120 MAX_AGE_IMAGE=14400 docker-clean.sh

```