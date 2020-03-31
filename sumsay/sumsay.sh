#!/bin/sh

sumsay() {
    local FILE
    local SUM

    for FILE in "$@"; do
        if [ -r "$FILE" ]; then
            # if this is a file on disk, we calculate the sum
            SUM=$(shasum -a 256 "$FILE" | \
                  perl -pe 's/^(.+?)\s.*$/$1/; s/(.)(?!$)/$1 /g; tr/a-z/A-Z/')
        else
            # if it is not a file, we assume it is a literal sum
            SUM="literal checksum $FILE"
        fi

        say -i -v tom "$FILE:" "$SUM"
    done
}
