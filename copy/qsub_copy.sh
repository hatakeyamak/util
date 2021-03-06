#!/bin/bash
#PBS -l nodes=1:ppn=1

#
# qsub -v filelist=list_Run2ProductionV1_Spring15_TTJets_TuneCUETP8M1.txt toDir=/store/user/hatake/ntuples/SusyRA2Analysis2015/Run2ProductionV2/ qsub_copy.sh
#

source ~cmssoft/shrc >& /dev/null
cd ~/CMSSW_8_0_1/src
eval `scramv1 runtime -sh`
cd $PBS_O_WORKDIR
echo 'hostname' `hostname`

export filelist=$filelist
export toDir=$toDir
export X509_USER_PROXY=~/.x509_user_proxy

export now=$(date +"%Y-%m-%d-%S")
echo $now
export FILENAME=`basename $filelist`
export tmpfile='/tmp/'$FILENAME'.'$now
cp $filelist $tmpfile

#
# Without Baylor SE    
mkdir -p '/data3/'$toDir
python ~/local/bin/data_replica_FNAL.py \
  --from-site CERN_EOS \
  $tmpfile 'file:////data3/'$toDir

# 
# With Baylor SE
#python ~/local/bin/data_replica.py \
# --from-site T3_US_FNALLPC \
# --to-site T3_US_Baylor \
# $tmpfile $toDir
