#!/bin/bash

export ORGPWD=$PWD

source ~cmssoft/shrc >& /dev/null
cd ~/CMSSW_8_0_1/src
eval `scramv1 runtime -sh`
export X509_USER_PROXY=~/.x509_user_proxy

cd $ORGPWD
mkdir -p tmp

IFS=$'\n'

export remote=srm://cmseos.fnal.gov:8443/srm/v2/server?SFN=//eos/uscms/store/user/hatake/copy
export remotePrefix=srm://cmseos.fnal.gov:8443/srm/v2/server?SFN=//

rm $ORGPWD/tmp/*.txt
echo 'For loop over files in a remote directory'
for f in `lcg-ls -l -b -D srmv2 $remote`; do
    export FILE=`echo $f | awk '{print $7}'`
    export LFN=`echo $FILE | sed -e 's/\/eos//' | sed -e 's/\/uscms//'`
    export FILENAME=`basename $LFN`
    echo $FILE $LFN $FILENAME
    lcg-cp -v -b -T srmv2 -D srmv2 -n 1 -V cms $remote"/"$FILENAME file:$PWD/tmp/$FILENAME
done

echo 'while loop'
cd tmp
grep -v '^#' < directory.list | { 
while read p; do
     export KEY=`echo $p | awk '{print $2}'`
     export DIR=`echo $p | awk '{print $1}'`
     echo $p $KEY $DIR
     touch $KEY'_missing.txt'
     grep 'store' < $KEY'.txt' | { 
	 while read q; do
	     export FILE=`echo $q | awk '{printf("/data3/%s",$1)}'`
	     export remoteFileTime=`echo $q | awk '{print $2}'`
	     if [ -f "$FILE" ];
	     then
		 echo "File $FILE exist." > /dev/null
		 export localFileTime=`stat -c %Y $FILE`
		 #echo $remoteFileTime $localFileTime
                 if [ $remoteFileTime -gt $localFileTime ];
		 then
		     echo "File $FILE does exist but local file is obsolete."
		     #echo $q
		     echo $q >> $KEY'_missing.txt'
                 else
		     echo "File $FILE exist and local file is up-to-date." > /dev/null
                 fi
	     else
		 echo "File $FILE does not exist"
		 echo $q >> $KEY'_missing.txt'
	     fi
#    export KEY=`echo $p | awk '{print $2}'`
#    export DIR=`echo $p | awk '{print $1}'`
#    echo $p $KEY $DIR
#    #split --lines=2000 $KEY.txt $KEY'_split'
#    split --lines=100 $KEY.txt $KEY'_split'
#    for f in `ls | grep $KEY'_split'`; do
#	echo $f
#	qsub -q moonshot -N $f -v filelist=$f,toDir=$DIR ../qsub_copy.sh
#    done
     done } 
#     awk '{print $0}' $KEY'.txt' 
#    cat $KEY'_tmp.txt'
#    #split --lines=2000 $KEY.txt $KEY'_split'
#    split --lines=100 $KEY.txt $KEY'_split'
#    for f in `ls | grep $KEY'_split'`; do
#	echo $f
#	qsub -q moonshot -N $f -v filelist=$f,toDir=$DIR ../qsub_copy.sh
#    done
done } 


#rm $ORGPWD/tmp/*_split*
#cd tmp
#grep -v '^#' < directory.list | { 
#while read p; do
#    export KEY=`echo $p | awk '{print $2}'`
#    export DIR=`echo $p | awk '{print $1}'`
#    echo $p $KEY $DIR
#    #split --lines=2000 $KEY.txt $KEY'_split'
#    split --lines=100 $KEY.txt $KEY'_split'
#    for f in `ls | grep $KEY'_split'`; do
#	echo $f
#	qsub -q moonshot -N $f -v filelist=$f,toDir=$DIR ../qsub_copy.sh
#    done
#done } 
