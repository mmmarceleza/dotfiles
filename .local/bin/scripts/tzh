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

line=$(tsh ls | sed '1,2d' | fzf --select-1 --reverse --exact ${host:+--query "$host"})
host=$(awk '{print $1}' <<<"$line")
user=$(sed -e 's/.*user=\([-_\.a-z0-9]\+\).*/\1/' <<<"$line")

if [ -z "$host" ]; then
    echo  "Not found or cancelled"
    exit 1
fi

cmd="tsh ssh ${params[@]} ${user:-$USERNAME}@$host ${cmd[@]}"
echo "$cmd" >&2
exec $cmd
