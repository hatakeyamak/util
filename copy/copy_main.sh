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

# split _missing.txt and _obsolete.txt, submit jobs
rm $ORGPWD/tmp/*_split*
cd tmp
grep -v '^#' < directory.list | { 
while read p; do
    export KEY=`echo $p | awk '{print $2}'`
    export DIR=`echo $p | awk '{print $1}'`
    echo $p $KEY $DIR
    #split --lines=2000 $KEY.txt $KEY'_split'
    split --lines=1000 $KEY'_missing.txt' $KEY'_m_split'
    for f in `ls | grep $KEY'_m_split'`; do
	echo $f
	qsub -q moonshot -N $f -v filelist=$f,toDir=$DIR ../qsub_copy.sh
    done
    split --lines=1000 $KEY'_obsolete.txt' $KEY'_o_split'
    for f in `ls | grep $KEY'_o_split'`; do
	echo $f
	qsub -q moonshot -N $f -v filelist=$f,toDir=$DIR ../qsub_copy.sh
    done
done } 
