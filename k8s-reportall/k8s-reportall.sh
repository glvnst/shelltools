#!/bin/sh

main() {
  (
    printf '# %s\n\n' "k8 resources as of $(date)"

    for resource in $(kubectl api-resources -o name); do
      printf '## %s\n\n```\n' "$resource"
      kubectl get -A "$resource"
      printf '```\n\n'
    done

    printf '%s\n' '---'
  ) 2>&1 | tee "k8s_resources_$(date '+%Y-%m-%d-%H-%M-%S').md"
}

[ -n "$IMPORT" ] || main "$@"
