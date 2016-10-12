
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
ls -l tmp/*obsolete*.txt         # if this is not empty, you should think about deleting these old local files. probably files are updated remotely, so the local files are obsolete.
```

```
bash copy_aux.sh  2              # look at kodiak directories and making lists of "missing" files
bash copy_main.sh 2              # submit jobs based on lists of "missing" files
bash check_copy_directories.sh
```