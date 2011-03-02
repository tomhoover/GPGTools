#!/bin/sh

# Quit Apple Mail
osascript -e "quit app \"Mail\""

# fix permissions (http://gpgtools.lighthouseapp.com/projects/65764-gpgmail/tickets/134)
sudo mkdir -p "$HOME/Library/Mail/Bundles"
sudo chown -R $USER:Staff "$HOME/Library/Mail/Bundles"
sudo chmod 755 "$HOME/Library/Mail/Bundles"

# remove old version of bundle
rm -rf "$HOME/Library/Mail/Bundles/GPGMail.mailbundle"
# remove possible leftovers of previous installations
rm -rf "/tmp/GPGMail_Installation"
