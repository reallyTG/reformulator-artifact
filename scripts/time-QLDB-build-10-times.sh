#!/bin/bash

# ATM: Run this from Scripts.

projName=$2
pathToProj=$1

# Do this 10 times +1 warmup:
for i in {1..11} 
do
    # Remove old QLDB.
    rm -rf /data/TaintAnalysis/QLDBs/$projName

    # time QLDB build, and put most of the output in the garbage.
    time ./make-database.sh $1 $2 > /dev/null 2>&1
done