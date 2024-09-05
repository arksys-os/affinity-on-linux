#!/bin/bash

# Fetch the webpage and save it to a file
curl -s "https://store.serif.com/en-us/update/windows/photo/2/" > page.html

# Extract the complete href link (including the query string after .exe)
link=$(grep -zoP '(?s)<div[^>]*role="menu"[^>]*>.*?</div>' page.html | grep -oP 'href="\K[^"]+\.exe[^"]*')

# Decode HTML entities
link=$(echo "$link" | sed 's/&amp;/&/g')

# Ensure the extracted link is a complete URL
if [[ $link != http* ]]; then
    # If it's a relative URL, prepend the base URL
    link="https://store.serif.com$link"
fi

# Print the full link
echo "$link"

# Cleanup
rm page.html
