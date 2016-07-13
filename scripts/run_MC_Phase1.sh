#!/bin/bash

#modes:   1 = 2016, 2 = 2017 (no QIE11), 3 = 2017 (full)
#process: 0 = SinglePionE50, 1 = ZMM, 2 = ZEE, 3 = TTbar
MODE=0
NPROC=0
DIR=.
ID=0
SEED=-1

#check arguments
while getopts ":m:p:s:i:d:" opt; do
  case "$opt" in
  m) MODE=$OPTARG
    ;;
  p) NPROC=$OPTARG
    ;;
  s) SEED=$OPTARG
    ;;
  i) ID=$OPTARG
    ;;
  d) DIR=$OPTARG
    ;;
  esac
done

if [[ $MODE -eq 0 || $MODE -gt 3 ]]; then
  echo "Unknown mode $MODE"
  exit 1
fi

echo $DIR
mkdir -p $DIR
cd $DIR

#default settings for HF 2016
if [[ $MODE -eq 1 ]]; then
  COND="auto:run2_mc"
  ERA="Run2_2016"
  GEOM="Configuration.Geometry.GeometryExtended2016dev_cff,Configuration.Geometry.GeometryExtended2016devReco_cff"
  SLHC="SLHCUpgradeSimulations/Configuration/HCalCustoms.customise_Hcal2016"
elif [[ $MODE -eq 2 ]]; then
  COND="auto:phase1_2017_design"
  ERA="Run2_2017"
  GEOM="Configuration.Geometry.GeometryExtended2017dev_cff,Configuration.Geometry.GeometryExtended2017devReco_cff"
  SLHC="SLHCUpgradeSimulations/Configuration/HCalCustoms.customise_Hcal2017"
elif [[ $MODE -eq 3 ]]; then
  COND="auto:phase1_2017_design"
  ERA="Run2_2017"
  GEOM="Configuration.Geometry.GeometryExtended2017dev_cff,Configuration.Geometry.GeometryExtended2017devReco_cff"
  SLHC="SLHCUpgradeSimulations/Configuration/HCalCustoms.customise_Hcal2017Full"
else
  echo "Unknown mode $MODE"
  exit 1
fi  

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

echo $CONFIG $PROCESS $NEV $ID $SEED

awk 'BEGIN{printf("import os\n");printf("seed = int(os.environ.get(\047SEED\047,\047 123456789\047))\n");printf("idnum = int(os.environ.get(\047ID\047, \047 0\047))\n");printf("outfile = \047file:step1_\047+str(idnum)+\047.root\047\n");printf("\n")}/EmptySource/{printf("process.RandomNumberGeneratorService.generator.initialSeed = seed\n")}/Additional/{printf("process.FEVTDEBUGoutput.fileName = cms.untracked.string(outfile)\n");}{print $0}' ${CONFIG}_cfi_GEN_SIM.py >& ${CONFIG}_cfi_GEN_SIM_run.py

awk 'BEGIN{printf("import os\n");printf("seed = int(os.environ.get(\047SEED\047,\047 123456789\047))\n");printf("idnum = int(os.environ.get(\047ID\047, \047 0\047))\n");printf("infile = \047file:step1_\047+str(idnum)+\047.root\047\n");printf("outfile = \047file:step2_\047+str(idnum)+\047.root\047\n");printf("\n")}/EmptySource/{printf("process.RandomNumberGeneratorService.generator.initialSeed = seed\n")}/Production/{printf("process.source.fileNames = cms.untracked.vstring(infile)\n");}/Additional/{printf("process.FEVTDEBUGHLToutput.fileName = cms.untracked.string(outfile)\n");}{print $0}' step2_DIGI_L1_DIGI2RAW_HLT.py >& step2_DIGI_L1_DIGI2RAW_HLT_run.py

awk 'BEGIN{printf("import os\n");printf("seed = int(os.environ.get(\047SEED\047,\047 123456789\047))\n");printf("idnum = int(os.environ.get(\047ID\047, \047 0\047))\n");printf("infile = \047file:step2_\047+str(idnum)+\047.root\047\n");printf("outfile = \047file:step3_\047+str(idnum)+\047.root\047\n");printf("outfile2 = \047file:step3_\047+str(idnum)+\047_inMINIAODSIM.root\047\n");printf("\n")}/EmptySource/{printf("process.RandomNumberGeneratorService.generator.initialSeed = seed\n")}/Production/{printf("process.source.fileNames = cms.untracked.vstring(infile)\n");}/Additional/{printf("process.RECOSIMoutput.fileName = cms.untracked.string(outfile)\n");printf("process.MINIAODSIMoutput.fileName = cms.untracked.string(outfile2)\n");}{print $0}' step3_RAW2DIGI_L1Reco_RECO_EI_PAT.py >& step3_RAW2DIGI_L1Reco_RECO_EI_PAT_run.py


exit

