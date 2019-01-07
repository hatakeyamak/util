#!/bin/bash

source ~cmssoft/shrc >& /dev/null
cd ~/CMSSW_8_0_1/src
eval `scramv1 runtime -sh`
cd -
pwd
echo 'hostname' `hostname`

while read line; do
  echo "$line"
  python copyfiles.py local '/cms/data//store/user/hatake/'$line T3_US_FNALLPC $line -p gfal -r -eu hcal_upgrade -t 864000
done < $1
