#!/bin/bash
#PBS -l nodes=1:ppn=1

#
# qsub -v filelist=list_Run2ProductionV1_Spring15_TTJets_TuneCUETP8M1.txt toDir=/store/user/hatake/ntuples/SusyRA2Analysis2015/Run2ProductionV2/ qsub_copy.sh
#

cd $PBS_O_WORKDIR
source ~cmssoft/shrc

export filelist=$filelist
export toDir=$toDir
export X509_USER_PROXY=~/.x509_user_proxy

#
# Without Baylor SE    
mkdir -p '/data3/'$toDir
python ~/local/bin/data_replica.py \
  --from-site T3_US_FNALLPC \
  $filelist 'file:////data3/'$toDir

# 
# With Baylor SE
#python ~/local/bin/data_replica.py \
#  --from-site T3_US_FNALLPC \
# --to-site T3_US_Baylor 
# $filelist $toDir

