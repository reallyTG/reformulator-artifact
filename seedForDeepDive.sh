#!/bin/bash

# Make sure database services are running.
service postgresql start
service mysql start

# There are five applications with a deep-dive:
# 1. youtubeclone
# 2. eventbright
# 3. NetSteam
# 4. property-manage
# 5. employee-tracker

#
# 1. youtubeclone is already set up, since the database is hosted online

#
# 2. eventbright
cd /home/evaluation/case-studies/eventbright/backend

# Setup 10
cp .env.10 .env
cp reformulator-seed-files/20220303215346-event-seeds.js.10 db/seeders/20220303215346-event-seeds.js
npx dotenv sequelize-cli db:create      
npx dotenv sequelize-cli db:migrate     
npx dotenv sequelize-cli db:seed:all    

# Setup 100
cp .env.100 .env
cp reformulator-seed-files/20220303215346-event-seeds.js.100 db/seeders/20220303215346-event-seeds.js
npx dotenv sequelize-cli db:create      
npx dotenv sequelize-cli db:migrate     
npx dotenv sequelize-cli db:seed:all    

# You guessed it, setup 1000
cp .env.1000 .env
cp reformulator-seed-files/20220303215346-event-seeds.js.1000 db/seeders/20220303215346-event-seeds.js
npx dotenv sequelize-cli db:create      
npx dotenv sequelize-cli db:migrate     
npx dotenv sequelize-cli db:seed:all    

# Reset to basic -- It's already set up.
cp .env.basic .env
cp reformulator-seed-files/20220303215346-event-seeds.js.basic db/seeders/20220303215346-event-seeds.js

#
# 3. NetSteam
cd /home/evaluation/case-studies/NetSteam/backend

# Setup 10
cp .env.10 .env
cp reformulator-seeders/5-ReviewSeeder.js.10 db/seeders/5-ReviewSeeder.js
npx dotenv sequelize-cli db:create      
npx dotenv sequelize-cli db:migrate     
npx dotenv sequelize-cli db:seed:all    

# Setup 100
cp .env.100 .env
cp reformulator-seeders/5-ReviewSeeder.js.100 db/seeders/5-ReviewSeeder.js
npx dotenv sequelize-cli db:create      
npx dotenv sequelize-cli db:migrate     
npx dotenv sequelize-cli db:seed:all    

# Setup 1000
cp .env.1000 .env
cp reformulator-seeders/5-ReviewSeeder.js.1000 db/seeders/5-ReviewSeeder.js
npx dotenv sequelize-cli db:create      
npx dotenv sequelize-cli db:migrate     
npx dotenv sequelize-cli db:seed:all    

# Reset to basic -- It's already set up.
cp .env.basic .env
cp reformulator-seeders/5-ReviewSeeder.js.basic db/seeders/5-ReviewSeeder.js

#
# 4. property-manage
cd /home/evaluation/case-studies/property-manage/backend

# Setup 10
cp .env.10 .env
cp reformulator-seeders/20210203162156-seed-properties.js.10 db/seeders/20210203162156-seed-properties.js

# Setup 100
cp .env.100 .env
cp reformulator-seeders/20210203162156-seed-properties.js.100 db/seeders/20210203162156-seed-properties.js

# Setup 1000
cp .env.1000 .env
cp reformulator-seeders/20210203162156-seed-properties.js.1000 db/seeders/20210203162156-seed-properties.js

# Reset to basic -- It's already set up.
cp .env.basic .env
cp reformulator-seeders/20210203162156-seed-properties.js.basic db/seeders/20210203162156-seed-properties.js

#
# 5. employee-tracker
cd /home/evaluation/case-studies/employee-tracker

# Setup 10
cp .env.10 .env
cp reformulator-seeders/seed.js.10 seeds/seed.js
node seeds/seed.js
node seeds/seed.js # Run twice because key constraints fail first time...

# Setup 100
cp .env.100 .env
cp reformulator-seeders/seed.js.100 seeds/seed.js
node seeds/seed.js
node seeds/seed.js # Run twice because key constraints fail first time...

# Setup 1000
cp .env.1000 .env
cp reformulator-seeders/seed.js.1000 seeds/seed.js
node seeds/seed.js
node seeds/seed.js # Run twice because key constraints fail first time...

# Reset to basic -- It's already set up.
cp .env.basic .env
cp reformulator-seeders/seed.js.basic seeds/seed.js

# Clean it up.
rm /home/seedForDeepDive.sh