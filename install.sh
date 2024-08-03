#!/bin/bash

chown alireza:alireza -R ./volumes/nginx
chown nobody:alireza -R ./volumes/litespeed/sites

find ./volumes/litespeed/sites -type f -exec chmod 0660 {} \;
find ./volumes/litespeed/sites -type d -exec chmod 0770 {} \;
