#!/usr/bin/env bash

names=`git log --since==$1 --until=$2 --format='%aN' | sort -u`

#| while read name; do echo -en "$name"; git log --since==2019-04-01 --until=2019-04-08 --author="$name" --pretty=tformat: --name-status | awk -F' ' '{if ($1 == "A" && $NF ~ /^*.md$/) add += 1} END {print add}' -; done
echo -e "$1 ~ $2\n"
for name in $names
do
    echo -en "${name}\t"
    
    git log --since==$1 --until=$2 --author="$name" --pretty=tformat: --name-status | awk -F' ' '{if ($1 == "A" && $NF ~ /^*.md$/) add += 1} END {print add}'

done
