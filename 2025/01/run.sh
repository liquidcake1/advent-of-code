#!/bin/bash
dirname=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
input=$(readlink -f "$2")
cd ~/src/befunge2
node funge.mjs "$dirname/$1" < "$input"
echo
echo "Done!"
