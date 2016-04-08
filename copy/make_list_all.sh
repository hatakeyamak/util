#!/bin/bash

IFS=$'\n'

rm *.txt
grep -v '^#' < directory.list | { 
while read p; do
    export KEY=`echo $p | awk '{print $2}'`
    export DIR=`echo $p | awk '{print $1}'`
    echo $p
    ./make_list.sh $DIR >& $KEY.txt
done } #< directory.list

eos root://cmseos.fnal.gov rm -r /eos/uscms/store/user/hatake/copy
eos root://cmseos.fnal.gov mkdir /eos/uscms/store/user/hatake/copy
xrdcp *.txt /eos/uscms/store/user/hatake/copy/.
xrdcp *.list /eos/uscms/store/user/hatake/copy/.

#for p in `cat directory.txt`; do
#    echo $p
#done
