#!/bin/bash

export lfnDirectory=$1
#echo $lfnDirectory $string

export dateStr=`date --date='-365 days' +"%Y-%m-%d %H:%M:%S"`
timestamp=$(date -d "$dateStr" +%s)

IFS=$'\n'

#for curFile in *; do
#for f in $(ls -1); do 
for f in `xrdfs root://cmseos.fnal.gov ls -l $(echo $lfnDirectory)`; do
    #echo $f 
    export DATE=`echo $f | awk '{print $2,$3}'`
    export FILE=`echo $f | awk '{print $5}'`
    #echo $DATE
    curFileMtime=$(date -d "$DATE" +%s)
    #curFileMtime=$(stat -c %Y "$curFile")
    #xrdfs root://cmseos.fnal.gov ls -l $f | awk '{print $2}'
    #echo $curFileMtime $DATE $timestamp $dateStr
    if (( curFileMtime > timestamp )); then
        echo $FILE
    fi
done
