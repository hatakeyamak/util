#!/bin/bash

IFS=$'\n'

rm *_kodiak.txt
grep -v '^#' < directory.list | { 
while read p; do
    touch 'tmp/'$KEY'_kodiak.txt'
    export KEY=`echo $p | awk '{print $2}'`
    export DIR=`echo $p | awk '{print $1}'`
    echo $p
    echo $DIR
    #./make_list_kodiak.sh $DIR
    ./make_list_kodiak.sh $DIR >& 'tmp/'$KEY'_kodiak.txt'
done } #< directory.list

#eos root://cmseos.fnal.gov rm -r /eos/uscms/store/user/hatake/copy
#eos root://cmseos.fnal.gov mkdir /eos/uscms/store/user/hatake/copy
#xrdcp *.txt /eos/uscms/store/user/hatake/copy/.
#xrdcp *.list /eos/uscms/store/user/hatake/copy/.

#for p in `cat directory.txt`; do
#    echo $p
#done
