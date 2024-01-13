#!/bin/bash

# 查找与 move.sh 相关的进程并终止
pid=$(ps aux | grep 'move.sh' | grep -v 'grep' | awk '{print $2}')

if [ -n "$pid" ]; then
    echo "Terminating process with PID: $pid"
    kill "$pid"
else
    echo "No matching process found."
fi
