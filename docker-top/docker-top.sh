#!/bin/sh

# this is useful with VM-based docker environments like "docker desktop for mac"

exec docker run --rm -it --privileged --pid=host alpine:edge nsenter -t 1 -m -u -n -i top
