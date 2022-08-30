#!/bin/bash

cd /home/evaluation

# `reformulator` is built on node 16.
nvm use 16

#
# youtubeclone
# Build database.
./scripts/make-database.sh ./case-studies/youtubeclone/ youtubeclone-backend

# Run the query.
./scripts/run-query.sh youtubeclone-backend find-sequelize-flows

# Also run the stats query.
./scripts/run-query.sh youtubeclone-backend getStats

# Run transformation.
node /home/reformulator/orm-refactoring/dist/transform.js --mode=CodeQL \
    --pathTo=/home/evaluation/case-studies/youtubeclone/youtubeclone-backend/ \
    --flows=/home/evaluation/query-results/find-sequelize-flows/youtubeclone-backend.csv \
    --models=/home/evaluation/case-studies/youtubeclone/youtubeclone-backend/src/models/ \
    --sequelize-file=/home/evaluation/case-studies/youtubeclone/youtubeclone-backend/src/sequelize.js

#
# eventbright
# Build database.
./scripts/make-database.sh ./case-studies/eventbright/ eventbright

# Run the query.
./scripts/run-query.sh eventbright find-sequelize-flows

# Also run the stats query.
./scripts/run-query.sh eventbright getStats

# Run transformation.
# There isn't really a sequelize-file for this one.
node /home/reformulator/orm-refactoring/dist/transform.js --mode=CodeQL \
    --pathTo=/home/evaluation/case-studies/eventbright/ \
    --flows=/home/evaluation/query-results/find-sequelize-flows/eventbright.csv \
    --models=/home/evaluation/case-studies/eventbright/backend/db/models/ \
    --sequelize-file=/home/evaluation/case-studies/eventbright/backend/db/models/index.js

#
# employee-tracker
# Build database.
./scripts/make-database.sh ./case-studies/employee-tracker/ employee-tracker

# Run the query.
./scripts/run-query.sh employee-tracker find-sequelize-flows

# Also run the stats query.
./scripts/run-query.sh employee-tracker getStats

# Run transformation.
# There isn't really a sequelize-file for this one.
node /home/reformulator/orm-refactoring/dist/transform.js --mode=CodeQL \
    --pathTo=/home/evaluation/case-studies/employee-tracker/ \
    --flows=/home/evaluation/query-results/find-sequelize-flows/employee-tracker.csv \
    --models=/home/evaluation/case-studies/employee-tracker/models/ \
    --sequelize-file=/home/evaluation/case-studies/employee-tracker/config/connection.js 

#
# property-manage
# Build database.
./scripts/make-database.sh ./case-studies/property-manage/ property-manage 

# Run the query.
./scripts/run-query.sh property-manage find-sequelize-flows

# Also run the stats query.
./scripts/run-query.sh property-manage getStats

# Run transformation.
node /home/reformulator/orm-refactoring/dist/transform.js --mode=CodeQL \
    --pathTo=/home/evaluation/case-studies/property-manage/ \
    --flows=/home/evaluation/query-results/find-sequelize-flows/property-manage.csv \
    --models=/home/evaluation/case-studies/property-manage/backend/db/models/ \
    --sequelize-file=/home/evaluation/case-studies/property-manage/backend/db/models/index.js

#
# wall
# Build database.
./scripts/make-database.sh ./case-studies/wall/ wall

# Run the query.
./scripts/run-query.sh wall find-sequelize-flows

# Also run the stats query.
./scripts/run-query.sh wall getStats

# Run transformation.
node /home/reformulator/orm-refactoring/dist/transform.js --mode=CodeQL \
    --pathTo=/home/evaluation/case-studies/wall/ \
    --flows=/home/evaluation/query-results/find-sequelize-flows/wall.csv \
    --models=/home/evaluation/case-studies/wall/models/ \
    --sequelize-file=/home/evaluation/case-studies/wall/models/init-models.js

#
# Math_Fluency_App
# Build database.
./scripts/make-database.sh ./case-studies/Math_Fluency_App/ Math_Fluency_App

# Run the query.
./scripts/run-query.sh Math_Fluency_App find-sequelize-flows

# Also run the stats query.
./scripts/run-query.sh Math_Fluency_App getStats

# Run transformation.
node /home/reformulator/orm-refactoring/dist/transform.js --mode=CodeQL \
    --pathTo=/home/evaluation/case-studies/Math_Fluency_App/ \
    --flows=/home/evaluation/query-results/find-sequelize-flows/Math_Fluency_App.csv \
    --models=/home/evaluation/case-studies/Math_Fluency_App/models/ \
    --sequelize-file=/home/evaluation/case-studies/Math_Fluency_App/database.js

#
# Graceshopper-Elektra
# Build database.
./scripts/make-database.sh ./case-studies/Graceshopper-Elektra/ Graceshopper-Elektra

# Run the query.
./scripts/run-query.sh Graceshopper-Elektra find-sequelize-flows

# Also run the stats query.
./scripts/run-query.sh Graceshopper-Elektra getStats

# Run transformation.
node /home/reformulator/orm-refactoring/dist/transform.js --mode=CodeQL \
    --pathTo=/home/evaluation/case-studies/Graceshopper-Elektra/ \
    --flows=/home/evaluation/query-results/find-sequelize-flows/Graceshopper-Elektra.csv \
    --models=/home/evaluation/case-studies/Graceshopper-Elektra/server/db/models/ \
    --sequelize-file=/home/evaluation/case-studies/Graceshopper-Elektra/server/db/models/index.js 

#
# NetSteam
# Build database.
./scripts/make-database.sh ./case-studies/NetSteam/ NetSteam

# Run the query.
./scripts/run-query.sh NetSteam find-sequelize-flows

# Also run the stats query.
./scripts/run-query.sh NetSteam getStats

# Run transformation.
node /home/reformulator/orm-refactoring/dist/transform.js --mode=CodeQL \
    --pathTo=/home/evaluation/case-studies/NetSteam/ \
    --flows=/home/evaluation/query-results/find-sequelize-flows/NetSteam.csv \
    --models=/home/evaluation/case-studies/NetSteam/backend/db/models/ \
    --sequelize-file=/home/evaluation/case-studies/NetSteam/backend/db/models/index.js

#
#
# Print Table 1
./scripts/print-table-1.sh