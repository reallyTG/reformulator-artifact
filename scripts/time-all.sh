#!/bin/bash

cd /home/evaluation

# Reset to start.
./scripts/reset-case-studies-to-original.sh

# Clear QLDBs.
rm -rf /home/evaluation/QLDBs/*

# Need to time ...
# (0) ... npm i for reference:
echo "NetSteam npm install time"
cd /home/evaluation/case-studies/NetSteam
rm -rf frontend/node_modules
rm -rf backend/node_modules
time npm i > /dev/null 2>&1

echo "Graceshopper-Elektra npm install time"
cd /home/evaluation/case-studies/Graceshopper-Elektra/
rm -rf node_modules
time npm i > /dev/null 2>&1

echo "Math_Fluency_App npm install time"
cd /home/evaluation/case-studies/Math_Fluency_App/
rm -rf node_modules
time npm i > /dev/null 2>&1

echo "employee-tracker npm install time"
cd /home/evaluation/case-studies/employee-tracker/
rm -rf node_modules
time npm i > /dev/null 2>&1

echo "eventbright npm install time"
cd /home/evaluation/case-studies/eventbright/
rm -rf frontend/node_modules
rm -rf backend/node_modules
rm -rf node_modules
time npm i > /dev/null 2>&1

echo "property-manage npm install time"
cd /home/evaluation/case-studies/property-manage/
rm -rf frontend/node_modules/ backend/node_modules/
time npm i > /dev/null 2>&1

echo "wall npm install time"
cd /home/evaluation/case-studies/wall/
rm -rf node_modules
time npm i > /dev/null 2>&1

echo "youtubeclone-backend npm install time"
cd /home/evaluation/case-studies/youtubeclone/youtubeclone-backend/
rm -rf node_modules
time npm i > /dev/null 2>&1

# (Go back to `/home/evaluation`.)
cd /home/evaluation

# (1) ... QLDB builds:
echo "NetSteam QLDB build time"
time ./scripts/make-database.sh ./case-studies/NetSteam/ NetSteam  > /dev/null 2>&1
echo "Graceshopper-Elektra QLDB build time"
time ./scripts/make-database.sh ./case-studies/Graceshopper-Elektra/ Graceshopper-Elektra  > /dev/null 2>&1
echo "Math_Fluency_App QLDB build time"
time ./scripts/make-database.sh ./case-studies/Math_Fluency_App/ Math_Fluency_App  > /dev/null 2>&1
echo "wall QLDB build time"
time ./scripts/make-database.sh ./case-studies/wall/ wall  > /dev/null 2>&1
echo "property-manage QLDB build time"
time ./scripts/make-database.sh ./case-studies/property-manage/ property-manage > /dev/null 2>&1
echo "employee-tracker QLDB build time"
time ./scripts/make-database.sh ./case-studies/employee-tracker/ employee-tracker > /dev/null 2>&1
echo "eventbright QLDB build time"
time ./scripts/make-database.sh ./case-studies/eventbright/ eventbright > /dev/null 2>&1
echo "youtubeclone-build QLDB build time"
time ./scripts/make-database.sh ./case-studies/youtubeclone/ youtubeclone-backend > /dev/null 2>&1

# (2) ... query run times:
echo "NetSteam query run time"
time ./scripts/run-query.sh NetSteam find-sequelize-flows > /dev/null 2>&1
echo "Graceshopper-Elektra query run time"
time ./scripts/run-query.sh Graceshopper-Elektra find-sequelize-flows > /dev/null 2>&1
echo "Math_Fluency_App query run time"
time ./scripts/run-query.sh Math_Fluency_App find-sequelize-flows > /dev/null 2>&1
echo "wall query run time"
time ./scripts/run-query.sh wall find-sequelize-flows > /dev/null 2>&1
echo "property-manage query run time"
time ./scripts/run-query.sh property-manage find-sequelize-flows > /dev/null 2>&1
echo "employee-tracker query run time"
time ./scripts/run-query.sh employee-tracker find-sequelize-flows > /dev/null 2>&1
echo "eventbright query run time"
time ./scripts/run-query.sh eventbright find-sequelize-flows > /dev/null 2>&1
echo "youtubeclone-backend query run time"
time ./scripts/run-query.sh youtubeclone-backend find-sequelize-flows > /dev/null 2>&1

# (3) ... but not the transformations b/c they are so fast.