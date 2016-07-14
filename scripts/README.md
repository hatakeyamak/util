
Creating basic configuration files
------------------------------
```
./util/scripts/MC_Phase1.sh -p 1 -m 1 -e 100 -d ZMM_2016_v11 -n
./util/scripts/MC_Phase1.sh -p 1 -m 2 -e 100 -d ZMM_2017_v11 -n
./util/scripts/MC_Phase1.sh -p 1 -m 3 -e 100 -d ZMM_2017full_v11 -n
```

Creating modified configuration files in order to run several parallel jobs (and run locally)
---------------------------------------------------------------------------------------------
```
./util/scripts/run_MC_Phase1.sh -p 1 -d ZMM_2016_v11
./util/scripts/run_MC_Phase1.sh -p 1 -d ZMM_2016_v11 -s 1 -i 1 -r 

./util/scripts/run_MC_Phase1.sh -p 1 -d ZMM_2017_v11
./util/scripts/run_MC_Phase1.sh -p 1 -d ZMM_2017_v11 -s 1 -i 1 -r

./util/scripts/run_MC_Phase1.sh -p 1 -d ZMM_2017full_v11
./util/scripts/run_MC_Phase1.sh -p 1 -d ZMM_2017full_v11 -s 1 -i 1 -r
```

Submit to pbs
-------------
```
qsub -v nproc=1,dir=ZMM_2016_v11,seed=2,id=2 ./util/scripts/qsub_run.sh 

for i in {1..100}; do qsub -q anderson -N ZMM_2016_${i} -v nproc=1,dir=ZMM_2016_v11,seed=$i,id=$i ./util/scripts/qsub_run.sh; sleep 1; done

for i in {1..100}; do qsub -q anderson -N ZMM_2017_${i} -v nproc=1,dir=ZMM_2017_v11,seed=$i,id=$i ./util/scripts/qsub_run.sh; sleep 1; done

for i in {1..100}; do qsub -q anderson -N ZMM_2017f_${i} -v nproc=1,dir=ZMM_2017full_v11,seed=$i,id=$i ./util/scripts/qsub_run.sh; sleep 1; done
```

Copy to LPC
-----------
```
python ~/local/bin/data_replica.py --from-site T3_US_Baylor --to-site T3_US_FNALLPC list.txt /store/user/hcal_upgrade/hcal_relval/CMSSW_8_1_0_pre8/ZMM_2016
```

