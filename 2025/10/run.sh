#!/bin/bash

erlc "$1"
mod=${1%.erl}
erl -noshell -eval "$mod:solve(\"$2\", \"$PART\")"
