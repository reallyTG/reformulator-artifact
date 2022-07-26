#!/bin/bash

# Inputs
# Note: make sure query is in the correct location.
queryLocation=/home/reformulator/reformulator-analysis

projName=$1
query=$2
pathToQuery=$queryLocation/$2.ql

# Constants
QLDBs=/home/evaluation/QLDBs
Results=/home/evaluation/query-results/$query

mkdir -p $Results

codeql query run --database $QLDBs/${projName} --output=$Results/${projName}_tempOut.bqrs $pathToQuery
codeql bqrs decode --format=csv $Results/${projName}_tempOut.bqrs > $Results/${projName}.csv
rm $Results/${projName}_tempOut.bqrs
