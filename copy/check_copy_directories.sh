#!/bin/bash

IFS=$'\n'

export local=/data3

cd tmp
grep -v '^#' < directory.list | { 
while read p; do
    export KEY=`echo $p | awk '{print $3}'`
    export LIST=`echo $p | awk '{print $2}'`
    export DIR=`echo $p | awk '{print $1}'`
    echo $LIST $DIR $KEY
    wc -l $LIST.txt
    if [ -n "$KEY" ]; then
	ls -F $local/$DIR/ | grep -v "/" | grep $KEY | wc -l
    else
	ls -F $local/$DIR/ | grep -v "/" | wc -l
    fi
    echo
done }
