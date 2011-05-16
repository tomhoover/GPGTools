#!/bin/sh

# Old version must not run in the background
killall GPGServices
sleep 1
killall -9 GPGServices

# Remove (old) versions
rm -rf $HOME/Library/Services/GPGServices.service
rm -rf /Library/Services/GPGServices.service

mkdir -p /Library/Services/
#chown -R $USER $HOME/Library/Services/
mv /private/tmp/GPGServices.service /Library/Services/
#chown -R $USER $HOME/Library/Services/

./ServicesRestart
sleep 3
sudo ./ServicesRestart

exit 0

