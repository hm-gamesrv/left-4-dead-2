#!/bin/bash
set -u

export LD_LIBRARY_PATH="/app/bin:/app${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

cd /app && exec /app/srcds_linux \
    -game left4dead2 \
    -insecure \
    -port 27015 \
    +exec server.cfg \
    "$@"

pid=$!

# 引擎作为 PID 1 会忽略 SIGTERM，这里代为转发，docker stop 才能立刻生效
trap "kill -TERM $pid 2>/dev/null" TERM

while :; do
    wait "$pid"; status=$?
    kill -0 "$pid" 2>/dev/null || break
done
exit "$status"