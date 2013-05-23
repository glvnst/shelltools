#!/bin/bash

export CONC_MAX=2

conc () 
{ 
    local procs=(`jobs -p`);
    local proc_count=${#procs[*]};

    # Block until there is an open slot
    if ((proc_count >= CONC_MAX)); then
        wait;
    fi;

    # Start our task
    ( eval "$@" ) &
}
export -f conc


xconc () 
{ 
    local command=$1;
    shift;
    local arg_count=${#@};
    local group_size=$(( arg_count / CONC_MAX ));
    local group_count=$(( (arg_count / group_size) + (arg_count % group_size ? 1 : 0) ));
    (
        local i;
        local start;
        for ((i = 0; i < group_count; i++ ))
        do
            start=$(( (i * group_size) + 1 ));
            conc "$command ${@:$start:$group_size}";
        done;
        wait
    )
}
export -f xconc
