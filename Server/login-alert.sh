#!/bin/bash

BOT_TOKEN=""
CHAT_ID=""
URL="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"

HOSTNAME=$(hostname -f)
DATE="$(date +"%Y/%b/%d-%H:%M:%S")"

# Create a pretty table using printf or column
PRETTY_TABLE=$(printf " \
                      HOSTNAME    $HOSTNAME \n  \
                      DATE        $DATE \n      \
                      USER        $PAM_USER \n  \
                      Action      $PAM_TYPE \n  \
                      Source_IP   $PAM_RHOST    \
                      " | column -t)

# Format the table for Telegram's markdown
FORMATTED_TABLE=$(echo -e "\`\`\`\n$PRETTY_TABLE\n\`\`\`")

# Encode the message for URL
ENCODED_MESSAGE=$(echo -n "$FORMATTED_TABLE" | jq -sRr @uri)

curl -s -X POST $URL \
  -d chat_id="$CHAT_ID" \
  -d text="$ENCODED_MESSAGE" \
  -d parse_mode="MarkdownV2" 2>&1 /dev/null

exit 0
