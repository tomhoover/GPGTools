#!/bin/sh

# Add the gpg-agent helper Script to login items for the current user:
osascript -e 'tell application "System Events" to make new login item at end with properties {path:"/usr/local/libexec/start-gpg-agent.app", hidden:true}' > /dev/null

# Stop the agent
killall gpg-agent
# Start the agent under the logged in user
sudo -u $USER /usr/local/libexec/start-gpg-agent.app/Contents/MacOS/start-gpg-agent