#!/bin/bash

. /unsloth/unsloth_studio/bin/activate
export PYTHONPATH=/usr/local/lib/python3.12/dist-packages:$PYTHONPATH

# Ensure we use the unsloth.sh as entrypoint
if [ "$1" = "bash" ] || [ "$1" = "/bin/bash" ]; then
    exec "$@"
fi

# If no command is provided, default to unsloth studio
if [ $# -eq 0 ]; then
    exec unsloth studio
fi

exec "$@"
