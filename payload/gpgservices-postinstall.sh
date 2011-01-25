#!/bin/sh

mkdir -p $HOME/Library/Services/
mv /Users/Shared/GPGServices.service $HOME/Library/Services/

mkdir -p $HOME/Library/PreferencePanes/
mv /Users/Shared/GPGTools.prefPane $HOME/Library/PreferencePanes/

./ServicesRestart
sleep 3
sudo ./ServicesRestart

exit 0

