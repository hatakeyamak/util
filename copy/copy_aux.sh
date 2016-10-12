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
    printenv remote remotePrefix
    gfal-ls $remote
    for f in `gfal-ls $remote`; do
	export FILE=`echo $f | awk '{print $1}'`
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
	    export LIST=`echo $p | awk '{print $2}'`
	    export DIR=`echo $p | awk '{print $1}'`
	    #export MODE=`echo $p | awk '{print $3}'`
	    echo $p $LIST $DIR

	    if [ $type -eq 1 ]; then
		rm    $LIST'_copy.txt'
		touch $LIST'_copy.txt'
		awk '{print $1}' $LIST'.txt' > $LIST'_copy.txt' 

	    elif [ $type -eq 2 ]; then 
		rm    $LIST'_missing.txt'
		touch $LIST'_missing.txt'
		grep 'store' < $LIST'.txt' | { 
		    while read LFN remoteFileTime; do
			export FILE='/data3'$LFN
			if [ -f "$FILE" ];
			then
			    echo "File $FILE exist." > /dev/null			
			else
			    echo "File $FILE does not exist" > /dev/null
			    echo $LFN >> $LIST'_missing.txt'
			fi
		    done } 

	    elif [ $type -eq 3 ]; then 
		rm    $LIST'_obsolete.txt'
		rm    $LIST'_kodiak.txt'
		rm    $LIST'_combined.txt'
		touch $LIST'_obsolete.txt'
		touch $LIST'_kodiak.txt'
		touch $LIST'_combined.txt'
		../make_list_kodiak.sh $DIR | sort >& $LIST'_kodiak.txt'
		sort -k1 $LIST'_kodiak.txt' | join $LIST'.txt' - >& $LIST'_combined.txt'
		grep 'store' < $LIST'_combined.txt' | { 
		    while read LFN remoteFileTime localFileTime; do

			if [ $remoteFileTime -gt $localFileTime ];
			then
			    echo "File $FILE does exist but local file is obsolete." > /dev/null
			    echo 'rm /data3'$LFN >> $LIST'_obsolete.txt'
			else
			    echo "File $FILE exist and local file is up-to-date." > /dev/null
			fi
			
		    done } 
	    fi
	done } 
fi
