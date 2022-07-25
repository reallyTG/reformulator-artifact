#!/bin/bash

# Make some directories.
mkdir -p /home/evaluation/case-studies
mkdir /home/evaluation/query-results
mkdir /home/evaluation/QLDBs

# Bring scripts over.
mv /home/scripts /home/evaluation/scripts

# Get all the code.
# Also, make sure they are at the right branch.
cd /home/evaluation/case-studies

# For youtubeclone, need to make an outer directory.
mkdir youtubeclone
cd youtubeclone
git clone https://github.com/TaintAnalysis-DB-Benchmarks/youtubeclone-backend.git
git clone https://github.com/TaintAnalysis-DB-Benchmarks/youtubeclone-frontend.git
cd youtubeclone-backend
git checkout orm-refactoring-original
# Frontend repo doesn't need to have a branch change.

# Back up.
cd ..

git clone https://github.com/TaintAnalysis-DB-Benchmarks/NetSteam
cd NetSteam
git checkout orm-refactoring-original
cd ..

git clone https://github.com/TaintAnalysis-DB-Benchmarks/property-manage
cd property-manage
git checkout orm-refactoring-original
cd ..

git clone https://github.com/TaintAnalysis-DB-Benchmarks/eventbright
cd eventbright
git checkout orm-refactoring-original
cd ..

git clone https://github.com/TaintAnalysis-DB-Benchmarks/wall
cd wall
git checkout orm-refactoring-original
cd ..

git clone https://github.com/TaintAnalysis-DB-Benchmarks/Math_Fluency_App
cd Math_Fluency_App
git checkout orm-refactoring-original
cd ..

git clone https://github.com/TaintAnalysis-DB-Benchmarks/Graceshopper-Elektra
cd Graceshopper-Elektra
git checkout orm-refactoring-original
cd ..

git clone https://github.com/TaintAnalysis-DB-Benchmarks/employee-tracker
cd employee-tracker
git checkout orm-refactoring-original
cd ..

rm makeEvaluation.sh
