#!/bin/sh

decrypt_caesar() {
    input="$1"
    shift="$2"
    decrypted=""
    
    i=0
    while [ $i -lt ${#input} ]; do
        char=$(echo "$input" | cut -c $((i + 1))) 
        ascii=$(printf "%d" "'$char")
        
        if [ "$ascii" -ge 65 ] && [ "$ascii" -le 90 ]; then
            new_ascii=$(( (ascii - 65 - shift + 26) % 26 + 65 ))
            new_char=$(printf "\\$(printf '%03o' "$new_ascii")")
        elif [ "$ascii" -ge 97 ] && [ "$ascii" -le 122 ]; then
            new_ascii=$(( (ascii - 97 - shift + 26) % 26 + 97 ))
            new_char=$(printf "\\$(printf '%03o' "$new_ascii")")
        else
            new_char="$char"
        fi

        decrypted="$decrypted$new_char"
        i=$((i + 1))
    done

    echo "$decrypted"
}

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <encrypted_text>"
    exit 1
fi

encrypted_text="$1"

for shift in $(seq 1 13); do
    decrypted_text=$(decrypt_caesar "$encrypted_text" "$shift")
    
    case "$decrypted_text" in
        # case accepted
        NYCUNASA\{????????????????\}) 
            echo "$decrypted_text"
            exit 0
            ;;
        # other cases
        *) 
            continue
            ;;
    esac
done

exit 1