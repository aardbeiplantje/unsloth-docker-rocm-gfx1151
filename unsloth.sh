#!/bin/bash
if [ "$@" = "" ]; then
    set -- bash
fi
exec "$*"
