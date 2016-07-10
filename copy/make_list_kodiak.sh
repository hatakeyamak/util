#!/bin/bash

export lfnDirectory=$1
export pfnDirectory=/data3/$1

export dateStr=`date --date='-365 days' +"%Y-%m-%d %H:%M:%S"`
timestamp=$(date -d "$dateStr" +%s)
#echo 'timestamp' $timestamp

IFS=$'\n'

ls $pfnDirectory -l --time-style=+"%Y/%m/%d/%H/%M/%S" | grep root | awk -v lfnDir=$lfnDirectory '{split($6,date,"/");time=mktime(date[1] " " date[2] " " date[3] " " date[4] " " date[5] " " date[6]); printf("%s/%s %d\n"),lfnDir,$7,time;}'
#ls $pfnDirectory | grep root | awk -v lfnDir=$lfnDirectory '{command="date -d" $1 " +%s"; command |getline $1; printf("%s/%s\n"),lfnDir,$1;}'

#for f in `ls -l --time-style=+"%Y-%m-%d %H:%M:%S" $(echo $pfnDirectory) | grep root`; do
#    export DATE=`echo $f | awk '{print $6,$7}'`
#    export FILE=`echo $f | awk '{print $8}'`
#    #export curFileStatTime=`stat -c %Y $pfnDirectory/$FILE`
#    #curFileMtime=$(date -d "$DATE" +%s)
#    #echo $DATE $FILE $curFileMtime $curFileStatTime
#    echo $lfnDirectory'/'$FILE
#    #if (( curFileMtime > timestamp )); then
#        #echo $lfnDirectory'/'$FILE $curFileStatTime
#    #fi
#done
