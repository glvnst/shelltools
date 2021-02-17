#!/bin/sh

docker container prune --force \
  | sed 's/^/container: /'

docker image prune --all --force --filter until=1440h \
  | sed 's/^/image: /'

# xargs --no-run-if-empty would be great here, but that option isn't available on BSDs
docker volume ls -qf dangling=true \
  | grep -E '^[0-9a-f]{64}$' \
  | (while read -r vol; do docker volume rm "$vol"; done) \
  | sed 's/^/volume: /'

docker network prune -f \
  | sed 's/^/network: /'
