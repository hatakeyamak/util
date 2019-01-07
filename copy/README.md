
Using LPC scripts
------
```
git clone git@github.com:FNALLPC/lpc-scripts.git
cd lpc-scripts
cp ../AAA*.txt
cp ../AAA*.sh
python copyfiles.py T3_US_FNALLPC \
 /Stop_production/Summer16_80X_Jan_2017_Ntp_v12X/ZZTo4Q_13TeV_amcatnloFXFX_madspin_pythia8/ local \
 /cms/data/store/user/lpcsusyhad/Stop_production/Summer16_80X_Jan_2017_Ntp_v12X/ZZTo4Q_13TeV_amcatnloFXFX_madspin_pythia8/ \
 -p gfal -r -su lpcsusyhad -t 86400
python copyfiles.py T3_US_FNALLPC \
 /Stop_production/Summer16_80X_Jan_2017_Ntp_v12X/WWW_4F_TuneCUETP8M1_13TeV-amcatnlo-pythia8/ local \
 /cms/data//store/user/lpcsusyhad/Stop_production/Summer16_80X_Jan_2017_Ntp_v12X/WWW_4F_TuneCUETP8M1_13TeV-amcatnlo-pythia8/ \
 -p gfal -r -su lpcsusyhad -t 86400
bash AAA_dir_copy.sh AAA_dir_list_part1.txt &>  AAA_dir_list_part1.log &
nohup bash AAA_dir_copy.sh AAA_dir_list_part2.txt &>AAA_dir_list_part2.log &
```


on lpc
------
```
edit directory.list
bash make_list_all.sh
```

on kodiak
---------
make sure data_replica.py in ~/local/bin

```
bash copy_aux.sh  0              # this copies necessary txt files from LPC to kodiak 
```

```
bash copy_aux.sh  3              # check locally existing files, in order to check if local files are newer than remote files.
ls -l tmp/*obsolete*.txt         # if this is not empty, you should think about deleting these old local files. probably files are updated remotely, so the local files are obsolete. If there are non-empty files, source them to clean up the obsolete files.
```

```
bash copy_aux.sh  2              # look at kodiak directories and making lists of "missing" files
bash copy_main.sh 2              # submit jobs based on lists of "missing" files
bash check_copy_directories.sh
```