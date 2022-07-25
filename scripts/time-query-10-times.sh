#!/bin/bash

# ATM: Run this from Scripts.

projName=$1

# Do this 10 times +1 warmup:
for i in {1..11} 
do
    # time the query run, and put most of the output in the garbage.
    time ./run-query.sh $1 find-sequelize-flows > /dev/null 2>&1
done