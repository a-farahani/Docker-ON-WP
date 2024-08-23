#!/bin/bash

## Get the OS name and version
OS_NAME=$(grep -oP '^ID=\K.*' /etc/os-release)
OS_VERSION=$(grep -oP '^VERSION_ID=\K.*' /etc/os-release | tr -d '"')
# Check if OS is Debian 12
if [[ "$OS_NAME" == "debian" && "$OS_VERSION" == "12" ]]; then
    echo "Running script on Debian 12..."
else
    echo "This script only runs on Debian 12."
    exit 1
fi

## Set variables
DOMAIN=$1
IP=$2
# Check if the variable is set
if [ -z "${DOMAIN}" ] || [ -z "${IP}" ]; then
    echo "Error: REQUIRED_VAR is not set."
    exit 1
fi

## Get the directory of the script
SCRIPT_DIR="$(dirname "$0")"
# Define the file path relative to the script's location
FILE_PATH="$SCRIPT_DIR/.env"
# Check if the file exists
if [[ ! -f "$FILE_PATH" ]]; then
    echo "Error: File $FILE_PATH does not exist."
    exit 1
fi

#################################################################################

## Install dependency
echo "#########################"
echo "Installing dependecies..."
apt install unzip apache2-utils -y

echo

## Donwload wordpress
echo "#########################"
echo "Downloading wordpress..."
wget -nc https://wordpress.org/latest.zip -O /tmp/wordpress.zip > /dev/null 2>&1
unzip -n /tmp/wordpress.zip -d /tmp > /dev/null
mkdir -p ./volumes/litespeed/sites/$DOMAIN/html
cp -ru /tmp/wordpress/* ./volumes/litespeed/sites/$DOMAIN/html/ > /dev/null

echo

## Config nginx
echo "#########################"
echo "Configuring nginx..."
sed -i "s@{{ DOMAIN }}@$DOMAIN@g" volumes/nginx/conf.d/default.conf
sed -i "s@{{ IP }}@$IP@g" volumes/nginx/conf.d/default.conf

echo "Creating dhparams..."
mkdir -p volumes/nginx/dhparam
openssl dhparam -out volumes/nginx/dhparam/dhparams.pem 4096

echo "Setting password..."
mkdir -p volumes/nginx/pass
chmod 755 volumes/nginx/pass -R

echo "Enter password for lsdash web"
htpasswd -c volumes/nginx/pass/.lsdash lsDashuserName

echo "Enter password for pma web"
htpasswd -c volumes/nginx/pass/.pma pMauserName

echo

## Start services
echo "#########################"
echo "Starting services..."
docker compose up -d

echo

## Set permissions
echo "#########################"
echo "Setting permissions"
chown 1000:1000 -R ./volumes/nginx
chown nobody:1000 -R ./volumes/litespeed/sites
find ./volumes/litespeed/sites -type f -exec chmod 0660 {} \;
find ./volumes/litespeed/sites -type d -exec chmod 0770 {} \;

echo

## Config litespeed
echo "#########################"
echo "Configuring litespeed..."
sed -i "s@secure                1@secure                0@g" volumes/litespeed/admin-conf/admin_config.conf
docker restart litespeed

echo "Enter username & password for litespeed"
docker exec -it litespeed /usr/local/lsws/admin/misc/admpass.sh

echo
