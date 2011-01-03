#!/bin/sh

# Create a new gpg.conf if none is existing from the skeleton file
if ( ! test -e $HOME/.gnupg/gpg.conf ) then
	echo "Create!"
	mkdir -p $HOME/.gnupg
	cp /usr/local/share/gnupg/options.skel $HOME/.gnupg/gpg.conf
fi