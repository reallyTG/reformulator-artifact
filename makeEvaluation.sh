#!/bin/bash

# Make some directories.
mkdir -p /home/evaluation/case-studies
mkdir /home/evaluation/query-results
mkdir /home/evaluation/QLDBs

# Bring scripts over.
mv /home/scripts /home/evaluation/scripts

rm makeEvaluation.sh
