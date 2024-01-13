#!/bin/bash

# 查找与 move.sh 相关的进程组并终止
pids=$(ps aux | grep 'move.sh' | grep -v 'grep' | awk '{print $2}')

if [ -n "$pids" ]; then
    echo "Terminating processes with PIDs: $pids"
    pkill -TERM -g "$pids"
else
    echo "No matching processes found."
fi
