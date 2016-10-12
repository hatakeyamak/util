
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
bash copy_aux.sh  2              # look at kodiak directories and making lists of "missing" files
bash copy_main.sh 2              # submit jobs based on lists of "missing" files
bash check_copy_directories.sh
```