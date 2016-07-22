#!/bin/bash

export lfnDirectory=$1
export pfnDirectory=/data3/$1

export dateStr=`date --date='-365 days' +"%Y-%m-%d %H:%M:%S"`
timestamp=$(date -d "$dateStr" +%s)
#echo 'timestamp' $timestamp

IFS=$'\n'

TZ=utc ls $pfnDirectory -l --time-style=+"%Y/%m/%d/%H/%M/%S" | grep root | awk -v lfnDir=$lfnDirectory '{split($6,date,"/");time=mktime(date[1] " " date[2] " " date[3] " " date[4] " " date[5] " " date[6]); printf("%s/%s %d\n"),lfnDir,$7,time;}' | sort


