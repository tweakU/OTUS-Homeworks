#!/bin/bash
echo -e "PID\tFD\tFILE"
for pid in /proc/[0-9]*; do
    if [ -d "$pid/fd" ]; then
        for fd in $pid/fd/*; do
            if [ -L "$fd" ]; then
                file=$(readlink "$fd")
                echo -e "$(basename $pid)\t$(basename $fd)\t$file"
            fi
        done
    fi
done
