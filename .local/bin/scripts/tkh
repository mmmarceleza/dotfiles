#!/bin/bash

host=""
cmd=()
params=(-A)

while [ $# -gt 0 ]; do
    case "$1" in
        -*) params+=("$1");;
        *)
           if [ -z "$host" ]; then
               host="${1}"
            else
                cmd+=("${1}")
            fi
    esac
    shift
done

line=$(tsh kube ls | sed '1,2d' | fzf --select-1 --reverse --exact ${host:+--query "$host"})
host=$(awk '{print $1}' <<<"$line")

if [ -z "$host" ]; then
    exit 1
fi

cmd="tsh kube login $host"
echo "$cmd" >&2
exec $cmd
