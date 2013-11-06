#!/bin/sh

fmt_duration() {
    # takes a number of seconds and prints it in years, hours, minutes, seconds
    # example usage:
    # $ fmt_duration 35000000
    # 1 year, 39 days, 20 hours, 13 minutes, 20 seconds
    #
    # Note: 1 year is treated as 365.25 days to account for "leap years"
    local -r -a labels=('years' 'days' 'hours' 'minutes' 'seconds');
    local -r -a increments=(31557600 86400 3600 60 1);
    local i label increment quantity
    local result=""
    local seconds=${1:-0}

    for ((i=0; i < ${#increments[@]}; i+=1)); do
        increment=${increments[i]}
        label=${labels[i]}

        if [ $seconds -ge $increment ]; then
            quantity=$((seconds / increment))
            if [ $quantity -eq 1 ]; then
                # Strip the "s" off the end for singular increments
                label=${label:0:${#label}-1}
            fi
            seconds=$(( seconds - (quantity * increment) ))
            result="${result} ${quantity} ${label},"
        fi
    done

    if [ ${#result} -eq 0 ]; then
        # "0 seconds" or 0 (whatever the final label is)
        echo "0 ${labels[${#labels[@]} - 1]}"
    else
        # exclude the final extraneous comma
        echo ${result:0:${#result}-1}
    fi
}

