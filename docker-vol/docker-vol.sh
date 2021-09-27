#!/bin/sh
# simple utility for reporting information about docker volumes
SELF="$(basename "$0" ".sh")"

DOCKER_INTERACTIVE=""

busybox_all_volumes() {
  # we're building the docker command in reverse
  # implicitly the arguments to this function (which form the
  # docker "CMD" / entrypoint arguments) appear first

  # next we add the docker image
  set -- "busybox:latest" "$@"

  # finally we have the arguments to the docker run command (which include the
  # volumes)
  for volume in $(docker volume ls -q); do
    set -- --volume="${volume}:/volumes/${volume}:ro" "$@"
  done

  [ -n "$DOCKER_INTERACTIVE" ] && set -- -it "$@"

  [ -n "$DEBUG" ] && set -x
  exec docker run \
    --rm \
    --entrypoint "/bin/sh" \
    --workdir "/volumes" \
    "$@" 
}

docker_volume_ls() {
  set -x
  exec docker volume ls -q "$@"
}

docker_volume_du() {
  busybox_all_volumes -c "/bin/du -hs *"
}

docker_volume_sh() {
  DOCKER_INTERACTIVE=1
  busybox_all_volumes
}

usage() {
  exception="$1"; shift
  [ -n "$exception" ] && printf 'ERROR: %s\n\n' "$exception"

  printf '%s\n' \
    "Usage: $SELF [-h|--help] [arg [...]]" \
    "" \
    "-h / --help   show this message" \
    "-d / --debug  print additional debugging messages" \
    '' \
    ' du - display disk usage statistics for all named volumes on the system' \
    ' ls - display a list of volumes' \
    ' sh - run POSIX-compliant command interpreter with all named volumes attached' \
    ' load    volname input_tarfile    - load a volume from a tar file' \
    ' save    volname [output_tarfile] - save a volume into a tar file' \
    ' loaddir volname input_dir        - load a volume from a directory' \
    ' savedir volname output_dir       - save a volume into a directory' \
    "" \
    "Docker volume related functions" \
    "" # no trailing slash

  [ -n "$exception" ] && exit 1
  exit 0
}

warn() {
  printf '%s %s %s\n' "$(date '+%FT%T%z')" "$SELF" "$*" >&2
}

die() {
  warn "FATAL:" "$@"
  exit 1
}

main() {
  while [ $# -gt 0 ]; do
    arg="$1" # shift at end of loop
    case "$arg" in
      -h|-help|--help)
        usage
        ;;

      -d|--debug)
        set -x
        ;;

      --mega-turtles)
        usage "You can't handle MEGA-TURTLES."
        ;;

      du)
        shift || true # shed the 'du'
        docker_volume_du "$@"
        ;;

      ls)
        shift || true # shed the 'ls'
        docker_volume_ls "$@"
        ;;

      sh)
        shift || true # shed the 'sh'
        docker_volume_sh "$@"
        ;;

      load)
        # load a volume from a tar file
        # load volname infile
        shift || die "load requires a volume name argument"
        volname="$1"

        shift || die "load requires an input file argument"
        infile="$1"
        [ -f "$infile" ] || die "load requires a valid, existing input file"

        # infile needs to be a full path, we might be able to accommodate relative files
        case "$infile" in
          /*)
            # already a full path, nothing to do
            ;;

          ./*)
            # relative path, prepend pwd
            infile="$(pwd)/${infile}"
            ;;

          *)
            # bare filename, also prepend pwd, probably
            infile="$(pwd)/${infile}"
            ;;
        esac
        [ -f "$infile" ] || die "failed to convert infile to a full path"

        case "$infile" in
          *.tar.gz|*.tgz)
            command="tar -xvzf /infile"
            ;;
          *.tar.xz|*.txz)
            command="tar -xvJf /infile"
            ;;
          *.tar.bz2|*.tar.bzip2|*.tbz2)
            command="tar -xvjf /infile"
            ;;
          *)
            die "unsupported format; try one of: tgz, txz, tbz2"
        esac

        set -x
        exec docker run \
          --rm \
          --interactive \
          --tty \
          --volume "${infile}:/src:ro" \
          --volume "${volname}:/dest" \
          --workdir "/dest" \
          "busybox:latest" \
          "sh" "-c" "${command}"
        ;;

      save)
        # save a volume into a tar file
        # save volname outputtar
        shift || die "save requires a volume name argument"
        volname="$1"

        shift || die "save requires an output file argument"
        outfile="${1:-${volname}-$(date "+%Y%m%d%H%M%S%z").tbz2}"
        [ -f "$outfile" ] && die "output file already exists"

        case "$outfile" in
          *.tar.gz|*.tgz)
            command="tar -cvzf - ."
            ;;
          # sadly xz is only supported for decompression in busybox
          # *.tar.xz|*.txz)
          #   command="tar --xz -cvf - ."
          #   ;;
          *.tar.bz2|*.tar.bzip2|*.tbz2)
            command="tar --bzip2 -cvf - ."
            ;;
          *)
            die "unsupported format; try one of: txz, tgz, tbz2"
        esac

        set -x
        exec docker run \
          --rm \
          --interactive \
          --volume "${volname}:/src:ro" \
          --workdir "/src" \
          "busybox:latest" \
          "sh" "-c" "${command}" \
          >"$outfile"
        ;;

      loaddir)
        # load a volume from a directory
        # loaddir volname input_dir
        shift || die "loaddir requires a volume name argument"
        volname="$1"

        shift || die "loaddir requires an input directory argument"
        input_dir="$1"
        [ -d "$input_dir" ] || die "loaddir requires a valid existing input directory argument"

        # input_dir needs to be a full path, we might be able to accommodate relative files
        case "$input_dir" in
          /*)
            # already a full path, nothing to do
            ;;

          ./*)
            # relative path, prepend pwd
            input_dir="$(pwd)/${input_dir}"
            ;;

          *)
            # bare filename, also prepend pwd, probably
            input_dir="$(pwd)/${input_dir}"
            ;;
        esac
        [ -d "$input_dir" ] || die "failed to convert input_dir into a full path"

        set -x
        exec docker run \
          --rm \
          --interactive \
          --volume "${input_dir}:/src:ro" \
          --volume "${volname}:/dest" \
          --workdir "/dest" \
          "busybox:latest" \
          "sh" "-c" "cp -Rpv /src/. /dest/."
        ;;

      savedir)
        # save a volume into a directory
        # savedir volname output_dir
        shift || die "savedir requires a volume name argument"
        volname="$1"

        shift || die "savedir requires an output directory argument"
        output_dir="$1"
        [ -f "$output_dir" ] && die "savedir requires a valid NON-EXISTING output directory argument"

        # output_dir needs to be a full path, we might be able to accommodate relative files
        case "$output_dir" in
          /*)
            # already a full path, nothing to do
            ;;

          ./*)
            # relative path, prepend pwd
            output_dir="$(pwd)/${output_dir}"
            ;;

          *)
            # bare filename, also prepend pwd, probably
            output_dir="$(pwd)/${output_dir}"
            ;;
        esac
        mkdir -p "$output_dir" || die "couldn't create output directory"

        set -x
        exec docker run \
          --rm \
          --interactive \
          --volume "${volname}:/src:ro" \
          --volume "${output_dir}:/dest" \
          --workdir "/dest" \
          "busybox:latest" \
          "sh" "-c" "cp -Rpv /src/. /dest/."
        ;;

      --)
        shift || true
        break
        ;;

      *)
        # unknown arg, leave it in the positional params
        break
        ;;
    esac
    shift || break
  done

  # ensure required environment variables are set
  # : "${USER:?the USER environment variable must be set}"

  # do things
  die "don't know how to do things"

  exit 0
}

[ -n "$IMPORT" ] || main "$@"; exit
