#!/bin/bash

## Get the OS name and version
OS_NAME=$(grep -oP '^ID=\K.*' /etc/os-release)
OS_VERSION=$(grep -oP '^VERSION_ID=\K.*' /etc/os-release | tr -d '"')

## Check if OS is Debian 12
if [[ "$OS_NAME" == "debian" && "$OS_VERSION" == "12" ]]; then
    echo "Running script on Debian 12..."
else
    echo "This script only runs on Debian 12."
    exit 1
fi

## Set variables
DOMAIN=$1

# Check if the variable is set
if [ -z "${DOMAIN}" ]; then
    echo "Error: REQUIRED_VAR is not set."
    exit 1
fi

## Install dependency
apt install unzip apache2-utils -y

## Donwload wordpress
wget -nc https://wordpress.org/latest.zip -O /tmp/wordpress.zip > /dev/null 2>&1
unzip -n /tmp/wordpress.zip -d /tmp > /dev/null
mkdir -p ./volumes/litespeed/sites/$DOMAIN/html
cp -ru /tmp/wordpress/* ./volumes/litespeed/sites/$DOMAIN/html/ > /dev/null

## Config nginx
sed -i "s@{{ DOMAIN }}@$DOMAIN@g" volumes/nginx/conf.d/default.conf

mkdir -p volumes/nginx/dhparam
openssl dhparam -out volumes/nginx/dhparam/dhparams.pem 4096

mkdir -p volumes/nginx/pass
chmod 755 volumes/nginx/pass -R
htpasswd -c volumes/nginx/pass/.lsdash lsDashuserName
htpasswd -c volumes/nginx/pass/.pma pMauserName

## Start services
docker compose up -d

## Set permissions
chown 1000:1000 -R ./volumes/nginx
chown nobody:1000 -R ./volumes/litespeed/sites
find ./volumes/litespeed/sites -type f -exec chmod 0660 {} \;
find ./volumes/litespeed/sites -type d -exec chmod 0770 {} \;

## Config litespeed
sed -i "s@secure                1@secure                0@g" volumes/litespeed/admin-conf/admin_config.conf
docker restart litespeed
docker compose run litespeed /usr/local/lsws/admin/misc/admpass.sh
