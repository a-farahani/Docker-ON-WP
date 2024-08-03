#!/bin/bash

###########################
DOMAIN=$1

# Check if the variable is set
if [ -z "${DOMAIN}" ]; then
    echo "Error: REQUIRED_VAR is not set."
    exit 1
fi
###########################

## donwload wordpress
wget -nc https://wordpress.org/latest.zip -O /tmp/wordpress.zip > /dev/null 2>&1
unzip -n /tmp/wordpress.zip -d /tmp > /dev/null
mkdir -p ./volumes/litespeed/sites/$DOMAIN/html
cp -ru /tmp/wordpress/* ./volumes/litespeed/sites/$DOMAIN/html/ > /dev/null

## set permissions
chown 1000:1000 -R ./volumes/nginx
chown nobody:1000 -R ./volumes/litespeed/sites
find ./volumes/litespeed/sites -type f -exec chmod 0660 {} \;
find ./volumes/litespeed/sites -type d -exec chmod 0770 {} \;

## config nginx
sed -i "s@{{ DOMAIN }}@$DOMAIN@g" volumes/nginx/conf.d/default.conf
