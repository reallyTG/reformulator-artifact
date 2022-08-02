#!/bin/bash

# Grab the Debian 10 compatible version of MySQL.
wget https://dev.mysql.com/get/mysql-apt-config_0.8.23-1_all.deb

# Needed to ensure that all the selections are made automatically.
debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password passMe"
debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password passMe"

# Add it to the package manager.
apt install ./mysql-apt-config_0.8.23-1_all.deb

# Install it for real.
# (Before installing for real, make absolutely sure that the public key for the MySQL install is available.)
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29
apt update
apt -y install mysql-server

# Clean this up.
rm installMySQL.sh
rm mysql-apt-config_0.8.23-1_all.deb