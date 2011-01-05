#!/bin/sh

# Fix a bug with an old GPGTools installation
	chown -R $USER:Staff $HOME/.gnupg

# Create a new gpg.conf if none is existing from the skeleton file
if ( ! test -e $HOME/.gnupg/gpg.conf ) then
	echo "Create!"
	mkdir -p $HOME/.gnupg
	chown -R $USER:Staff $HOME/.gnupg
	cp /usr/local/share/gnupg/options.skel $HOME/.gnupg/gpg.conf
fi