#!/bin/bash

type=$1
# 1: make copy list of files
# 2: list of missing files
# 3: list of obsolete files

export ORGPWD=$PWD

source ~cmssoft/shrc >& /dev/null
cd ~/CMSSW_8_0_1/src
eval `scramv1 runtime -sh`
export X509_USER_PROXY=~/.x509_user_proxy
echo 'hostname' `hostname`

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

    if [ $type -eq 1 ]; then

	split --lines=100 $KEY'_copy.txt' $KEY'_c_split'
	for f in `ls | grep $KEY'_c_split'`; do
	    echo $f
	    qsub -q moonshot -l walltime=48:00:00 -N $f -v filelist=$f,toDir=$DIR ../qsub_copy.sh
	done

    fi
    if [ $type -ge 2 ]; then

	split --lines=50 $KEY'_missing.txt' $KEY'_m_split'
	for f in `ls | grep $KEY'_m_split'`; do
	    echo $f
	    qsub -q moonshot -l walltime=48:00:00 -N $f -v filelist=$f,toDir=$DIR ../qsub_copy.sh
	done

    fi
    if [ $type -eq 3 ]; then

	split --lines=100 $KEY'_obsolete.txt' $KEY'_o_split'
	for f in `ls | grep $KEY'_o_split'`; do
	    echo $f
	    qsub -q moonshot -l walltime=48:00:00 -N $f -v filelist=$f,toDir=$DIR ../qsub_copy.sh
	done

    fi

done } 
