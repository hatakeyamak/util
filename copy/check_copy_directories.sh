#!/bin/bash

IFS=$'\n'

export local=/data3

cd tmp
grep -v '^#' < directory.list | { 
while read p; do
    export KEY=`echo $p | awk '{print $2}'`
    export DIR=`echo $p | awk '{print $1}'`
    echo $KEY $DIR
    wc -l $KEY.txt
    ls -F $local/$DIR/ | grep -v "/" | wc -l
    echo
done }
