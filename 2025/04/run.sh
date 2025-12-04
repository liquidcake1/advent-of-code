#!/bin/sh
set -ex
#~/owl/bin/ol -O2 -x c -o "$1".c "$1"
#gcc -O3 -x c -o "$1".elf "$1".c
./"$1".elf "$2"
#~/owl/bin/ol -r "$1" "$2"
