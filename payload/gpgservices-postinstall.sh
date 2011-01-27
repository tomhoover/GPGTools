#!/bin/sh

rm -rf $HOME/Library/Services/GPGServices.service
rm -rf /Library/Services/GPGServices.service

mkdir -p /Library/Services/
#chown -R $USER $HOME/Library/Services/
mv /private/tmp/GPGServices.service /Library/Services/
#chown -R $USER $HOME/Library/Services/

./ServicesRestart
sudo ./ServicesRestart

exit 0

