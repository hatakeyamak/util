
Check-out
------------------------------
```
git clone git@github.com:hatakeyamak/util.git
```

Creating basic configuration files
------------------------------
```
./util/scripts/MC_Phase1.sh -p 1 -m 0 -e 100 -d ZMM_run2_v11 -n -v
./util/scripts/MC_Phase1.sh -p 1 -m 1 -e 100 -d ZMM_2016_v11 -n -v
./util/scripts/MC_Phase1.sh -p 1 -m 2 -e 100 -d ZMM_2017_v11 -n -v
./util/scripts/MC_Phase1.sh -p 1 -m 3 -e 100 -d ZMM_2017full_v11 -n -v
```

Creating modified configuration files in order to run several parallel jobs (and run locally)
---------------------------------------------------------------------------------------------
```
./util/scripts/run_MC_Phase1.sh -p 1 -d ZMM_run2_v11
./util/scripts/run_MC_Phase1.sh -p 1 -d ZMM_run2_v11 -s 1 -i 1 -r >& log0.log &

./util/scripts/run_MC_Phase1.sh -p 1 -d ZMM_2016_v11
./util/scripts/run_MC_Phase1.sh -p 1 -d ZMM_2016_v11 -s 1 -i 1 -r >& log1.log &

./util/scripts/run_MC_Phase1.sh -p 1 -d ZMM_2017_v11
./util/scripts/run_MC_Phase1.sh -p 1 -d ZMM_2017_v11 -s 1 -i 1 -r >& log2.log &

./util/scripts/run_MC_Phase1.sh -p 1 -d ZMM_2017full_v11
./util/scripts/run_MC_Phase1.sh -p 1 -d ZMM_2017full_v11 -s 1 -i 1 -r >& log3.log &
```

Submit to pbs
-------------
```

for i in {2..100}; do qsub -l walltime=24:00:00 -q anderson -N ZMM_run2_${i} -v nproc=1,dir=ZMM_run2_v11,seed=$i,id=$i ./util/scripts/qsub_run.sh; sleep 1; done

for i in {2..100}; do qsub -l walltime=24:00:00 -q anderson -N ZMM_2016_${i} -v nproc=1,dir=ZMM_2016_v11,seed=$i,id=$i ./util/scripts/qsub_run.sh; sleep 1; done

for i in {2..100}; do qsub -l walltime=24:00:00 -q batch -N ZMM_2017_${i} -v nproc=1,dir=ZMM_2017_v11,seed=$i,id=$i ./util/scripts/qsub_run.sh; sleep 1; done

for i in {2..100}; do qsub -l walltime=24:00:00 -q batch -N ZMM_2017f_${i} -v nproc=1,dir=ZMM_2017full_v11,seed=$i,id=$i ./util/scripts/qsub_run.sh; sleep 1; done
```

Copy to LPC
-----------
```
python ~/local/bin/data_replica.py --from-site T3_US_Baylor --to-site T3_US_FNALLPC list.txt /store/user/hcal_upgrade/hcal_relval/CMSSW_8_1_0_pre8/ZMM_2016
```

