#!/bin/bash

export lfnDirectory=$1
#echo $lfnDirectory $string

export dateStr=`date --date='-365 days' +"%Y-%m-%d %H:%M:%S"`
timestamp=$(date -d "$dateStr" +%s)

IFS=$'\n'

xrdfs root://cmseos.fnal.gov ls -l $(echo $lfnDirectory) | grep root | awk '{split($2,date,"-");split($3,hms,":");time=mktime(date[1] " " date[2] " " date[3] " " hms[1] " " hms[2] " " hms[3]); printf("%s %d\n"),$5,time;}'

#for f in `xrdfs root://cmseos.fnal.gov ls -l $(echo $lfnDirectory) | grep root`; do
#    export DATE=`echo $f | awk '{print $2,$3}'`
#    export FILE=`echo $f | awk '{print $5}'`
#    #stat -c %Y /eos/uscms/$FILE
#    #export curFileStatTime=`stat -c %Y /eos/uscms/$FILE`
#    curFileMtime=$(date -d "$DATE" +%s)
#    if (( curFileMtime > timestamp )); then
#        echo $FILE $curFileMtime
#    fi
#done
