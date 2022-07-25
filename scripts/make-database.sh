#!/bin/bash

# Make sure the paths line up.
caseStudiesPath=/home/evaluation/case-studies
dbTgtDir=/home/evaluation/QLDBs
projName=$2
pathToProj=$1

# Create the DB.
codeql database create --language=javascript --source-root $pathToProj $dbTgtDir/$projName


