
./util/scripts/MC_Phase1.sh -p 1 -m 1 -e 100 -d WF1_ZMM_v11 -n >& WF1_ZMM_v11.log &
./util/scripts/MC_Phase1.sh -p 1 -m 2 -e 100 -d WF2_ZMM_v11 -n >& WF2_ZMM_v11.log &
./util/scripts/MC_Phase1.sh -p 1 -m 3 -e 100 -d WF3_ZMM_v11 -n >& WF3_ZMM_v11.log &

./util/scripts/run_MC_Phase1.sh -p 1 -d WF1_ZMM_v11
./util/scripts/run_MC_Phase1.sh -p 1 -d WF1_ZMM_v11 -s 1 -i 1 -r >& WF1_ZMM_v11_1.log &

./util/scripts/run_MC_Phase1.sh -p 1 -d WF2_ZMM_v11
./util/scripts/run_MC_Phase1.sh -p 1 -d WF2_ZMM_v11 -s 1 -i 1 -r >& WF2_ZMM_v11_1.log &

./util/scripts/run_MC_Phase1.sh -p 1 -d WF3_ZMM_v11
./util/scripts/run_MC_Phase1.sh -p 1 -d WF3_ZMM_v11 -s 1 -i 1 -r >& WF3_ZMM_v11_1.log &

qsub -v nproc=1,dir=WF1_ZMM_v11,seed=2,id=2 ./util/scripts/qsub_run.sh 

for i in {3..100}; do qsub -q batch    -v nproc=1,dir=WF1_ZMM_v11,seed=$i,id=$i ./util/scripts/qsub_run.sh; sleep 1; done

for i in {3..100}; do qsub -q anderson -v nproc=1,dir=WF2_ZMM_v11,seed=$i,id=$i ./util/scripts/qsub_run.sh; sleep 1; done

for i in {3..100}; do qsub -q moonshot -v nproc=1,dir=WF3_ZMM_v11,seed=$i,id=$i ./util/scripts/qsub_run.sh; sleep 1; done


