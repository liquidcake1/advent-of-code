#!/bin/bash
src="$1"
shift
ghc "$src" && ./"${src%.hs}" "$@"
