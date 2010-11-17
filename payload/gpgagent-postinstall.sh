#!/bin/sh

# Add the gpg-agent helper Script to login items for the current user:
osascript -e 'tell application "System Events" to make new login item at end with properties {path:"/usr/local/libexec/start-gpg-agent.app", hidden:true}' > /dev/null


# Add the üath to pinentry to gpg-agent.conf
PINENTRY_PATH=/usr/local/libexec/pinentry-mac.app/Contents/MacOS/pinentry-mac
GPGAGENT_CONF=~/.gnupg/gpg-agent.conf

if [[ -e "$GPGAGENT_CONF" ]] ;then
	sed '/^[	 ]*pinentry-program .*$/d' "$GPGAGENT_CONF" > "${GPGAGENT_CONF}_new" || exit 1
	echo "pinentry-program $PINENTRY_PATH" >> "${GPGAGENT_CONF}_new" || exit 1
	rm -f "$GPGAGENT_CONF" || exit 1
	mv "${GPGAGENT_CONF}_new" "$GPGAGENT_CONF" || exit 1
	rm -f "${GPGAGENT_CONF}_new" || exit 1
else
	echo "pinentry-program $PINENTRY_PATH" > "$GPGAGENT_CONF"
fi
