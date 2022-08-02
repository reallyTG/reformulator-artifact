#!/bin/bash

# We need nvm to use the wall project.
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 12
nvm install 16
nvm use 16
# ^ did this work?

# This will configure the database(s) in the artifact so that the applications can interact with them.
# Also, the projects will be installed and configured to talk to the database.

# Setup configuration for postgresql user.
# This overwrites the 'peer' permission on the postgresql user with 'trust',
# so no password is required.
cp /home/misc/pg_hba.conf /etc/postgresql/12/main/pg_hba.conf 

# Start PostgreSQL.
service postgresql start

# The PostgreSQL instance needs to be initialized with a password-ful admin,
# and the databases for some of the subject applications.
psql -U postgres -f /home/misc/init.psql

# Start MySQL.
service mysql start

# Read in the initial MySQL config.
# (!: before this command, root has no password. After, root has password 'passMe'.)
mysql -u root < /home/misc/init.sql

# Unpack the configuration files.
tar -xf /home/misc/Configs.tar.gz
rm /home/misc/Configs.tar.gz

# Seed the databases. ** This is the basic setup, the deep-dive setup comes later **

# wall ################################################################################
# Project setup:
nvm use 12
cd /home/evaluation/case-studies/wall
npm i
cd client
npm i 
cd ..
# Also copy over the images.
tar -xf /home/misc/wall-uploads.tar.gz
mv /home/misc/uploads .

# Database setup:
cp /home/misc/Configs/wall/.env* .
cp /home/misc/init__wall.sql .
mysql -u root --password=passMe < init__wall.sql
node seeders/seed-me.js

nvm use 16

# youtubeclone #########################################################################
# Project setup:
cd /home/evaluation/case-studies/youtubeclone/youtubeclone-frontend
npm i
npm run build
cd /home/evaluation/case-studies/youtubeclone/youtubeclone-backend
npm i
# Database setup:
cp /home/misc/Configs/youtubeclone/.env* /home/evaluation/case-studies/youtubeclone/youtubeclone-backend/
# --> no additional setup needes, as the db for ytc is online.

# Graceshopper-Elektra ################################################################
# Project setup:
cd /home/evaluation/case-studies/Graceshopper-Elektra
npm i npm-merge-driver dotenv webpack webpack-cli nodemon  # Missing dependencies.
npm i
npm run build-client

# Database setup:
cp /home/misc/Configs/Graceshopper-Elektra/.env .
npm run seed                    # To seed the DB.

# Math_Fluency_App ####################################################################
# Project setup:
cd /home/evaluation/case-studies/Math_Fluency_App
npm i

# Database setup:
cp /home/misc/Configs/Math_Fluency_App/.env .
node database_setup.js
node database_initialize_tables.js
mysql -u root -ppassMe < postman_tests/init__MathApp.sql 

# NetSteam ############################################################################
# Project setup:
cd /home/evaluation/case-studies/NetSteam
npm i
echo "JWT_EXPIRES_IN=9999" > .env

# Database setup:
cp /home/misc/Configs/NetSteam/.env* ./backend/
cd backend
npx dotenv sequelize-cli db:create      # basic DB
npx dotenv sequelize-cli db:migrate     # ^
npx dotenv sequelize-cli db:seed:all    # ^

# employee-tracker ####################################################################
# Project setup:
cd /home/evaluation/case-studies/employee-tracker
npm i

# Database setup:
cp /home/misc/Configs/employee-tracker/.env* .
node seeds/seed.js

# eventbright #########################################################################
# Project setup:
cd /home/evaluation/case-studies/eventbright
npm i

# Database setup:
cp /home/misc/Configs/eventbright/.env* ./backend/
cd backend
npx dotenv sequelize-cli db:create      # basic DB
npx dotenv sequelize-cli db:migrate     # ^
npx dotenv sequelize-cli db:seed:all    # ^

# property-manage #####################################################################
# Project setup:
cd /home/evaluation/case-studies/property-manage
npm i

# Database setup:
cp /home/misc/Configs/property-manage/.env* ./backend
cd backend
npx dotenv sequelize-cli db:create      # basic DB
npx dotenv sequelize-cli db:migrate     # ^
npx dotenv sequelize-cli db:seed:all    # ^

# Clean up
rm /home/setupProjects.sh
rm -rf /home/misc
rm -rf /home/Configs