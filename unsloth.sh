#!/bin/bash
set -e

# Ensure we use the unsloth.sh as entrypoint
if [ "$1" = "bash" ] || [ "$1" = "/bin/bash" ]; then
    shift
fi

# If no command is provided, default to bash
if [ $# -eq 0 ]; then
    exec bash
fi

exec "$@"
