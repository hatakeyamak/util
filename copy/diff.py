
f1 = open("missing.txt","w")
f2 = open("obsolete.txt","w")
f3 = open("disappeared.txt","w")

for line in file("tmp/V9.txt"):
    line = line.split( )
    lfn1 = line[0]
    time_lpc = line[1]
    #print(line)
    #print src
    #print dest
    checker = False    

    for row in file("tmp/V9_kodiak.txt"):
        row = row.split()
        lfn2 = row[0]
        time_kodiak = row[1]
        #print(row)
        #if (checker):
        #    break

        if(lfn1 == lfn2):
            checker = True
            #print lfn1,time_lpc,time_kodiak
            if (time_lpc > time_kodiak):
                print lfn1,time_lpc,time_kodiak
                f2.write(str(lfn1))
                f2.write('\n')
            break    

    if (checker == False):
        f1.write(str(lfn1))
        f1.write('\n')    

f1.close()
f2.close()
f3.close()
