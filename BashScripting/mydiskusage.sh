#!/bin/bash

if [[ $1 == '-d' ]]; then
  lists_dir=true
  shift 1
fi

if [[ $1 == '-n' && $2=~^[0-9]+$ ]]; then
  entries=$2
  shift 2
else
  entries=8
fi

list_disk_usage() {
  if [[ "$lists_dir" == true ]]; then
   du -ah $1 | sort -hr | head -$entries
else
   du -h --max-depth=1 $1 | sort -hr | head -$entries
fi
}

directory=$@
for dir in $directory; do
  list_disk_usage $dir
done