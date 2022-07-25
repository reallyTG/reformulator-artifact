#!/bin/bash

projDir=$1

# Go to CaseStudies directory.
cd $projDir

# Do this 10 times +1 warmup:
for i in {1..11} 
do
    # Remove node modules.
    rm -rf node_modules

    # time npm i, and put most of the output in the garbage.
    time npm i > /dev/null 2>&1
done