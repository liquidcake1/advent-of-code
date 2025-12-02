#!/bin/bash
psql -af <(while read -r I; do if [ "$I" = "INPUT_GOES_HERE" ]; then cat "$2"; else echo "$I"; fi; done < "$1")
