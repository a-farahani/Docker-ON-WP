#!/bin/bash

#######################################################################
# initial rules
iptables -N DOCKER-USER
iptables -F DOCKER-USER
iptables -A DOCKER-USER -s 172.17.0.0/16 -j ACCEPT
iptables -A DOCKER-USER -p tcp -m multiport --dports 80,443 -m geoip --source-country IR  -j ACCEPT

#######################################################################
# URL of the check-host.net IPv4 list
URL="https://check-host.net/nodes/ips"

# Temporary file to store the IP list
IP_LIST="/tmp/uptimerobot_ips.txt"

# Fetch the IP list from UptimeRobot
curl -s -H "Accept: application/json" "$URL" | jq .nodes[] > "$IP_LIST"

# Check if the file was downloaded successfully
if [[ ! -f "$IP_LIST" ]]; then
    echo "Failed to download the IP list from $URL"
    exit 1
fi

# Add new line end of file
echo >> $IP_LIST

# Loop through each IP address in the list
while IFS= read -r ip; do

    ip=$(echo "$ip" | tr -d '\r' | xargs)

    # Skip empty lines or lines that do not look like an IP address
    if [[ -z "$ip" || ! "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        continue
    fi

    # add rule
    iptables -A DOCKER-USER -s "$ip" -p tcp -m multiport --dports 80,443 -j ACCEPT

done < "$IP_LIST"

# Clean up the temporary file
rm -f "$IP_LIST"

echo "IP rules applied successfully."

#######################################################################
# last rules
iptables -A DOCKER-USER -j LOG --log-prefix "DOCKER-USER DROP LOG: "
iptables -A DOCKER-USER -p tcp -m multiport --dports 80,443 -j DROP
iptables -A DOCKER-USER -j RETURN




#########################################################################################################################3




#!/bin/bash

#######################################################################
# initial rules
iptables -N DOCKER-USER
iptables -F DOCKER-USER
iptables -A DOCKER-USER -s 172.17.0.0/16 -j ACCEPT
iptables -A DOCKER-USER -p tcp -m multiport --dports 80,443 -m geoip --source-country IR  -j ACCEPT

#######################################################################
# URL of the UptimeRobot IPv4 list
URL="https://uptimerobot.com/inc/files/ips/IPv4.txt"

# Temporary file to store the IP list
IP_LIST="/tmp/uptimerobot_ips.txt"

# Fetch the IP list from UptimeRobot
curl -s "$URL" -o "$IP_LIST"

# Check if the file was downloaded successfully
if [[ ! -f "$IP_LIST" ]]; then
    echo "Failed to download the IP list from $URL"
    exit 1
fi

# Add new line end of file
echo >> $IP_LIST

# Loop through each IP address in the list
while IFS= read -r ip; do

    ip=$(echo "$ip" | tr -d '\r' | xargs)

    # Skip empty lines or lines that do not look like an IP address
    if [[ -z "$ip" || ! "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        continue
    fi

    # add rule
    iptables -A DOCKER-USER -s "$ip" -p tcp -m multiport --dports 80,443 -j ACCEPT

done < "$IP_LIST"

# Clean up the temporary file
rm -f "$IP_LIST"

echo "IP rules applied successfully."

#######################################################################
# last rules
iptables -A DOCKER-USER -j LOG --log-prefix "DOCKER-USER DROP LOG: "
iptables -A DOCKER-USER -p tcp -m multiport --dports 80,443 -j DROP
iptables -A DOCKER-USER -j RETURN

