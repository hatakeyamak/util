#!/bin/bash

#modes:   1 = 2016, 2 = 2017 (no QIE11), 3 = 2017 (full)
#process: 0 = SinglePionE50, 1 = ZMM, 2 = ZEE, 3 = TTbar
MODE=0
EXTRA=""
VAL=""
DIR=.
NEV=10
NPROC=0
#ID=0
#SEED=-1

#check arguments
while getopts "d:e:p:m:nv" opt; do
  case "$opt" in
  m) MODE=$OPTARG
    ;;
  p) NPROC=$OPTARG
    ;;
  e) NEV=$OPTARG
    ;;
  d) DIR=$OPTARG
    ;;
  n) EXTRA="--no_exec"
    ;;
  v) VAL="val"
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

echo $CONFIG $PROCESS $NEV

cmsDriver.py ${CONFIG}_cfi  --conditions ${COND} -n ${NEV} --era ${ERA} --geometry ${GEOM} --eventcontent FEVTDEBUG -s GEN,SIM --datatier GEN-SIM --beamspot Realistic50ns13TeVCollision --fileout file:step1.root --customise ${SLHC} ${EXTRA} > step1_${PROCESS}_UP15+${PROCESS}_UP15+DIGIUP15+RECOUP15+HARVESTUP15.log  2>&1

#awk -v SEED=$SEED '/EmptySource/{printf("process.RandomNumberGeneratorService.generator.initialSeed = %d\n",SEED)}{print $0}' ${CONFIG}_cfi_GEN_SIM.py > ${CONFIG}_cfi_GEN_SIM_rndmseed.py

cmsDriver.py step2  --conditions ${COND} -s DIGI:pdigi_valid,L1,DIGI2RAW,HLT:@relval25ns --datatier GEN-SIM-DIGI-RAW-HLTDEBUG -n -1 --era ${ERA} --geometry ${GEOM} --eventcontent FEVTDEBUGHLT --filein file:step1.root  --fileout file:step2.root --customise ${SLHC} ${EXTRA} > step2_${PROCESS}_UP15+${PROCESS}_UP15+DIGIUP15+RECOUP15+HARVESTUP15.log  2>&1

if [[ -n "$VAL" ]]; then

cmsDriver.py step3  --runUnscheduled  --conditions ${COND} -s RAW2DIGI,L1Reco,RECO,EI,PAT,VALIDATION:@standardValidation+@miniAODValidation,DQM:@standardDQM+@miniAODDQM --datatier GEN-SIM-RECO,MINIAODSIM,DQMIO -n -1 --era ${ERA} --geometry ${GEOM} --eventcontent RECOSIM,MINIAODSIM,DQM --filein file:step2.root  --fileout file:step3.root --customise ${SLHC} ${EXTRA} > step3_${PROCESS}_UP15+${PROCESS}_UP15+DIGIUP15+RECOUP15+HARVESTUP15.log  2>&1

cmsDriver.py step4  --runUnscheduled  --conditions ${COND} -s HARVESTING:@standardValidation+@standardDQM+@miniAODValidation+@miniAODDQM -n -1 --era ${ERA} --geometry ${GEOM} --filetype DQM --filein file:step3_inDQM.root  --fileout file:step4.root --customise ${SLHC} ${EXTRA} > step4_${PROCESS}_UP15+${PROCESS}_UP15+DIGIUP15+RECOUP15+HARVESTUP15.log  2>&1

else

cmsDriver.py step3  --runUnscheduled  --conditions ${COND} -s RAW2DIGI,L1Reco,RECO,EI,PAT --datatier GEN-SIM-RECO,MINIAODSIM -n -1 --era ${ERA} --geometry ${GEOM} --eventcontent RECOSIM,MINIAODSIM --filein file:step2.root  --fileout file:step3.root --customise ${SLHC} ${EXTRA} > step3_${PROCESS}_UP15+${PROCESS}_UP15+DIGIUP15+RECOUP15+HARVESTUP15.log  2>&1

fi
