#!/bin/bash
set -euo pipefail

cd /app && exec /app/srcds_run \
    -game left4dead2 \
    -insecure \
    -port 27015 \
    -tickrate 64 \
    +exec server.cfg \
    +nomaster \
    "$@"
