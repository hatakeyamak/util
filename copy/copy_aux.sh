#!/bin/bash

type=$1
# 0: copy from cmslpc
# 1: make list of files (all files)
# 2: make list of missing files
# 3: make list of missing and obsolete files

export ORGPWD=$PWD

# Copy files from cmslpc
if [ $type -eq 0 ]; then

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
fi

# Make copy file lists
if [ $type -ge 1 ]; then

    echo 'while loop'
    cd tmp
    grep -v '^#' < directory.list | { 
	while read p; do
	    export KEY=`echo $p | awk '{print $2}'`
	    export DIR=`echo $p | awk '{print $1}'`
	    #export MODE=`echo $p | awk '{print $3}'`
	    echo $p $KEY $DIR

	    if [ $type -eq 1 ]; then
		rm    $KEY'_copy.txt'
		touch $KEY'_copy.txt'
		awk '{print $1}' $KEY'.txt' > $KEY'_copy.txt' 

	    elif [ $type -eq 2 ]; then 
		rm    $KEY'_missing.txt'
		touch $KEY'_missing.txt'
		grep 'store' < $KEY'.txt' | { 
		    while read LFN remoteFileTime; do
			export FILE='/data3'$LFN
			if [ -f "$FILE" ];
			then
			    echo "File $FILE exist." > /dev/null			
			else
			    echo "File $FILE does not exist" > /dev/null
			    echo $LFN >> $KEY'_missing.txt'
			fi
		    done } 

	    elif [ $type -eq 3 ]; then 
		rm    $KEY'_obsolete.txt'
		rm    $KEY'_kodiak.txt'
		rm    $KEY'_combined.txt'
		touch $KEY'_obsolete.txt'
		touch $KEY'_kodiak.txt'
		touch $KEY'_combined.txt'
		../make_list_kodiak.sh $DIR | sort >& $KEY'_kodiak.txt'
		sort -k1 $KEY'_kodiak.txt' | join $KEY'.txt' - >& $KEY'_combined.txt'
		grep 'store' < $KEY'_combined.txt' | { 
		    while read LFN remoteFileTime localFileTime; do

			if [ $remoteFileTime -gt $localFileTime ];
			then
			    echo "File $FILE does exist but local file is obsolete." > /dev/null
			    echo 'rm /data3'$LFN >> $KEY'_obsolete.txt'
			else
			    echo "File $FILE exist and local file is up-to-date." > /dev/null
			fi
			
		    done } 
	    fi
	done } 
fi
