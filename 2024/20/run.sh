#!/bin/bash
ssh -i ~/.ssh/id_stream $remote_vm 'vm-shared/run.sh' "$@"
