#!/bin/bash

# Maybe needed?
# rm /etc/apt/sources.list.d/nodesource.list
# cd /var/cache/apt/archives
# dpkg -i --force-overwrite 'nodejspackage.db'
# cd /home

# apt --fix-broken install
# apt update
# apt remove nodejs
# apt remove nodejs-doc

# Need curl.
apt-get update
apt-get -y install --no-install-recommends curl

curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs

rm /home/installNodeJS.sh