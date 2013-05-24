#!/bin/bash

COLLECT_LAST=""

collect () 
{ 
    # Check argument count, show help if incorrect
    if ((${#@} < 2)); then
        echo "Usage: collect <directory> <file to mv to directory> ..." 1>&2;
        echo "  * The directory will be created if it doesn't exist." 1>&2;
        return 1;
    fi;

    local directory=$1;
    shift;
    
    # Make the directory if necessary
    if [ '!' -d "$directory" ]; then
        mkdir -p "$directory";
    fi;

    # Do the move
    mv -i -- "$@" "$directory/";
    COLLECT_LAST="$directory";

    return 0
}
export -f collect


collectd () 
{ 
    # Check argument count, show help if incorrect
    if ((${#@} < 2)); then
        echo "Usage: collect <directory> <file to mv to directory> ..." 1>&2;
        echo "  * The directory will be created if it doesn't exist." 1>&2;
        echo "  * After the mv, 'pushd <directory>' will be called." 1>&2;
        return 1;
    fi;

    # collect, then cd to created directory
    collect "$@";
    pushd "$COLLECT_LAST";

    return 0
}
export -f collectd
