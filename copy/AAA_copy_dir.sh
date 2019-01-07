#!/bin/bash

source ~cmssoft/shrc >& /dev/null
cd ~/CMSSW_8_0_1/src
eval `scramv1 runtime -sh`
cd -
pwd
echo 'hostname' `hostname`

while read line; do
  echo "$line"
  python copyfiles.py T3_US_FNALLPC $line local '/cms/data//store/user/lpcsusyhad/'$line -p gfal -r -su lpcsusyhad -t 864000
done < $1
