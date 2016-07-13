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

    if [ $type -eq 1 ]; then
	rm $ORGPWD/tmp/*_copy.txt	
    elif [ $type -eq 2 ]; then 
	rm $ORGPWD/tmp/*_missing.txt	
    elif [ $type -eq 3 ]; then 
	rm $ORGPWD/tmp/*_obsolete.txt	
    elif [ $type -eq 4 ]; then 
	rm $ORGPWD/tmp/*_redundant.txt	
    fi

    echo 'while loop'
    cd tmp
    grep -v '^#' < directory.list | { 
	while read p; do
	    export KEY=`echo $p | awk '{print $2}'`
	    export DIR=`echo $p | awk '{print $1}'`
	    #export MODE=`echo $p | awk '{print $3}'`
	    echo $p $KEY $DIR
	    touch $KEY'_missing.txt'
	    touch $KEY'_obsolete.txt'

	    if [ $type -eq 1 ]; then
		awk '{print $1}' $KEY'.txt' > $KEY'_copy.txt' 

	    elif [ $type -eq 2 ]; then 
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
		rm 'tmp/'$KEY'_kodiak.txt'
		touch 'tmp/'$KEY'_kodiak.txt'
		./make_list_kodiak.sh $DIR | sort >& 'tmp/'$KEY'_kodiak.txt'
		grep 'store' < $KEY'.txt' | { 
		    while read LFN remoteFileTime; do
			export FILE='/data3'$LFN
			if [ -f "$FILE" ];
			then
			    echo "File $FILE exist." > /dev/null			
#			    if [ $type -ge 3 ]; then 
#
#				export localFileTime=`stat -c %Y $FILE`
#				if [ $remoteFileTime -gt $localFileTime ];
#				then
#				    echo "File $FILE does exist but local file is obsolete." > /dev/null
#				    echo $LFN >> $KEY'_obsolete.txt'
#				else
#				    echo "File $FILE exist and local file is up-to-date." > /dev/null
#				fi
#			    fi			    
			else
			    echo "File $FILE does not exist" > /dev/null
			    echo $LFN >> $KEY'_missing.txt'
			fi
		    done } 
	    fi
	done } 
fi
