#!/bin/bash
#PBS -l nodes=1:ppn=1

#
# ../util/scripts/run_MC_Phase1.sh -p 1 -d WF1_ZMM_v11 -s 1 -i 1 -r
#
# qsub -v nproc=1 dir=WF1_ZMM_v11 seed=1 id=1 ../../util/scripts/qsub_run.sh
#

source ~cmssoft/shrc >& /dev/null
cd $PBS_O_WORKDIR
eval `scramv1 runtime -sh`
echo 'hostname' `hostname`

#export seed=$seed
#export id=$id

export X509_USER_PROXY=~/.x509_user_proxy

./util/scripts/run_MC_Phase1.sh -p $nproc -d $dir -s $seed -i $id -r   

#
# Without Baylor SE    
#mkdir -p '/data3/'$toDir
#python ~/local/bin/data_replica.py \
#  --from-site T3_US_FNALLPC \
#  $filelist 'file:////data3/'$toDir

# 
# With Baylor SE
#python ~/local/bin/data_replica.py \
# --from-site T3_US_FNALLPC \
# --to-site T3_US_Baylor \
# $filelist $toDir

