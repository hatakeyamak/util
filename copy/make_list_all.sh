#!/bin/bash

IFS=$'\n'

rm *.txt
grep -v '^#' < directory.list | { 
while read p; do
    export KEY=`echo $p | awk '{print $3}'`  # Selection key word
    export LIST=`echo $p | awk '{print $2}'` # Name of the file list
    export DIR=`echo $p | awk '{print $1}'`  # Directory name
    echo $p $DIR $LIST $KEY 
    if [ -n "$KEY" ]; then
	./make_list.sh $DIR | grep $KEY >& $LIST.txt
    else
	./make_list.sh $DIR >& $LIST.txt
    fi
done } #< directory.list

eos root://cmseos.fnal.gov rm -r /eos/uscms/store/user/hatake/copy
eos root://cmseos.fnal.gov mkdir /eos/uscms/store/user/hatake/copy
xrdcp *.txt /eos/uscms/store/user/hatake/copy/.
xrdcp *.list /eos/uscms/store/user/hatake/copy/.

