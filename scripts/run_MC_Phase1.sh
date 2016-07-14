#!/bin/bash

#process: 0 = SinglePionE50, 1 = ZMM, 2 = ZEE, 3 = TTbar
NPROC=0
DIR=.
ID=0
SEED=-1
RUN=""

#check arguments
while getopts ":p:s:i:d:r" opt; do
  case "$opt" in
  p) NPROC=$OPTARG
    ;;
  s) SEED=$OPTARG
    ;;
  i) ID=$OPTARG
    ;;
  d) DIR=$OPTARG
    ;;
  r) RUN="run"
    ;;
  esac
done

#go to working directory
echo $DIR
mkdir -p $DIR
cd $DIR

#process
if [[ $NPROC -eq 0 ]]; then
  CONFIG=SinglePiE50HCAL_pythia8
  PROCESS=SinglePiE50
elif [[ $NPROC -eq 1 ]]; then
  CONFIG=ZMM_13TeV_TuneCUETP8M1
  PROCESS=ZMM
elif [[ $NPROC -eq 2 ]]; then
  CONFIG=ZEE_13TeV_TuneCUETP8M1
  PROCESS=ZEE
elif [[ $NPROC -eq 3 ]]; then
  CONFIG=TTbar_13TeV_TuneCUETP8M1
  PROCESS=TTbar
else
  echo "Unknown mode $NPROC"
  exit 1
fi  

#to print commands
set -x

echo $CONFIG $PROCESS $ID

if [ -f ${CONFIG}_cfi_GEN_SIM.py ]; then
if [ -f ${CONFIG}_cfi_GEN_SIM_run.py ]; then
 echo ${CONFIG}_cfi_GEN_SIM_run.py 'already exists'
else
awk 'BEGIN{printf("import os\n");
printf("seed = int(os.environ.get(\047SEED\047,\047 123456789\047))\n");
printf("idnum = int(os.environ.get(\047ID\047, \047 0\047))\n");
printf("outfile = \047file:step1_\047+str(idnum)+\047.root\047\n");
printf("\n")}
/EmptySource/{printf("process.RandomNumberGeneratorService.generator.initialSeed = seed\n")}
/Additional/{printf("process.FEVTDEBUGoutput.fileName = cms.untracked.string(outfile)\n");}
{print $0}' ${CONFIG}_cfi_GEN_SIM.py >& ${CONFIG}_cfi_GEN_SIM_run.py
fi
fi 

if [ -f step2_DIGI_L1_DIGI2RAW_HLT.py ]; then
if [ -f step2_DIGI_L1_DIGI2RAW_HLT_run.py ]; then
 echo 'step2_DIGI_L1_DIGI2RAW_HLT_run.py' 'already exists'
else 
awk 'BEGIN{printf("import os\n");
printf("idnum = int(os.environ.get(\047ID\047, \047 0\047))\n");
printf("infile = \047file:step1_\047+str(idnum)+\047.root\047\n");
printf("outfile = \047file:step2_\047+str(idnum)+\047.root\047\n");
printf("\n")}
/Production/{printf("process.source.fileNames = cms.untracked.vstring(infile)\n");}
/Additional/{printf("process.FEVTDEBUGHLToutput.fileName = cms.untracked.string(outfile)\n");}
{print $0}' step2_DIGI_L1_DIGI2RAW_HLT.py >& step2_DIGI_L1_DIGI2RAW_HLT_run.py
fi
fi

if [ -f step3_RAW2DIGI_L1Reco_RECO_EI_PAT.py ]; then
if [ -f step3_RAW2DIGI_L1Reco_RECO_EI_PAT_run.py ]; then
 echo 'step3_RAW2DIGI_L1Reco_RECO_EI_PAT_run.py' 'already exists'
else 
awk 'BEGIN{printf("import os\n");
printf("idnum = int(os.environ.get(\047ID\047, \047 0\047))\n");
printf("infile = \047file:step2_\047+str(idnum)+\047.root\047\n");
printf("outfile = \047file:step3_\047+str(idnum)+\047.root\047\n");
printf("outfile2 = \047file:step3_\047+str(idnum)+\047_inMINIAODSIM.root\047\n");
printf("\n")}
/Production/{printf("process.source.fileNames = cms.untracked.vstring(infile)\n");}
/Additional/
{printf("process.RECOSIMoutput.fileName = cms.untracked.string(outfile)\n");
printf("process.MINIAODSIMoutput.fileName = cms.untracked.string(outfile2)\n");}
{print $0}' step3_RAW2DIGI_L1Reco_RECO_EI_PAT.py >& step3_RAW2DIGI_L1Reco_RECO_EI_PAT_run.py
fi
fi

if [[ -n "$RUN" ]]; then

cmsRun ${CONFIG}_cfi_GEN_SIM_run.py             >& ${CONFIG}_cfi_GEN_SIM_run_${ID}.log
cmsRun step2_DIGI_L1_DIGI2RAW_HLT_run.py        >& step2_DIGI_L1_DIGI2RAW_HLT_run_${ID}.py
cmsRun step3_RAW2DIGI_L1Reco_RECO_EI_PAT_run.py >& step3_RAW2DIGI_L1Reco_RECO_EI_PAT_run_${ID}.log

fi

exit

