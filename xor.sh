#!/usr/bin/env bash

# The XOR cipher
# https://en.wikipedia.org/wiki/XOR_cipher
# https://www.dcode.fr/xor-cipher

keysize=0

# set debugging
# set -x

# convert an octal to a binary string
chrbin() {
    echo $(printf $(echo "ibase=2; obase=8; $1" | bc))
}

# convert a binary ASCII char to binary number
ordbin() {
    local a=$(printf "%d" "$1") # convert to octal
    echo "obase=2; $a" | bc
}

# convert ASCII text to binary
ascii2bin() {
    echo -n "$*" | while IFS= read -r -n1 char
    do
        ordbin "$char" | tr -d '\n'
        echo -n " "
    done
}

# convert binary to ASCII text
bin2ascii() {
    for bin in $*
    do
        chrbin "$bin" | tr -d '\n'
    done
}

# see: php.net/chr
chr() {
    local byte=$1
    while [[ $byte -lt 0 ]]; do
        byte=$(($byte + 256));
    done
    byte=$(($byte % 256));
    echo -e $byte
}

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    # remove whitespace in between characters
    var="${var//[[:space:]]/}"
    echo -n "$var"
}

xor() {
    local plaintext=($(text2ascii "$1"))
    local key=($(text2ascii "$2"))
    keysize=${#key[@]}
    local input_size=${#plaintext[@]}
    local cipher=""
    
    for ((i=0; i < $input_size; i++)); do
        local byte=$((${plaintext[$i]} ^ ${key[$i % $keysize]}))
        cipher="$cipher$(chr $byte)"
    done
    
    # output the cipher in decimal format
    echo -e "$cipher"
}

# test: https://www.browserling.com/tools/text-to-ascii
text2ascii() {
    declare -a str
    for ((i=0; i < ${#1}; i++)); do
        str[$i]=$(printf "%d" "'${1:$i:1}")
    done
    echo -e ${str[@]}
}

printf "%s %s\n" "Plaintext is:" "$1"
printf "%s %s\n" "Key is:" "$2"
cipher="$(xor "$1" "$2")"
printf "%s %s\n" "The cipher is (decimal):" "$cipher"
exit 0
