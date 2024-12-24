#!/bin/bash
set -o errexit
cd vm-shared
target_file="${1#vm-shared/src/}"
ssh -t stream-vm "(cd zig-day-23; ../zig-linux-x86_64-0.14.0-dev.2557+f06ca14cb/zig build-exe src/$target_file)"
target_exe="${target_file%.zig}"
ssh stream-vm "zig-day-23/$target_exe" < ../"$2"
