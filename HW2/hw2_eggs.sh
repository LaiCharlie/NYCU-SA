#!/bin/sh

temp_file=$(mktemp)

while [ "$(wc -l < "$temp_file")" -lt 10 ]; do
    output=$(./hw2_test.sh JOIN_NYCU_CSIT)

    if ! grep -Fxq "$output" "$temp_file"; then
        echo "$output" >> "$temp_file"

        output=${output#?}
        output=${output%?}

        echo "$output"
    fi
done

rm "$temp_file"
