#!/bin/bash
#
# This script creates a DMG  for GPGTools
#
# (c) by Felix Co & Alexander Willner
#

if ( ! test -e Makefile ) then
	echo "Wrong directory..."
	exit 1
fi

echo "Compiling GPGServices...";
(cd ../GPGServices && git pull && make && cd - && rm -rf payload/gpgservices/GPGServices.service && cp -r ../GPGServices/build/Release/GPGServices.service payload/gpgservices/) > build.log 2>&1
if [ ! "$?" == "0" ]; then echo "ERROR. Look at build.log"; exit 1; fi
echo "Compiling GPGKeychainAccess..."
(cd ../GPGKeychainAccess && git pull && make && cd - && rm -rf payload/keychain_access/Applications/GPG\ Keychain\ Access.app && cp -r ../GPGKeychainAccess/build/Release/GPG\ Keychain\ Access.app payload/keychain_access/Applications/)  > build.log 2>&1
if [ ! "$?" == "0" ]; then echo "ERROR. Look at build.log"; exit 1; fi
echo "Compiling GPGMail...";
(cd ../GPGMail/GPGMail && git pull && make && cd - && rm -rf payload/gpgmail/GPGMail.mailbundle && cp -r ../GPGMail/GPGMail/build/Release/GPGMail.mailbundle payload/gpgmail/)  > build.log 2>&1
if [ ! "$?" == "0" ]; then echo "ERROR. Look at build.log"; exit 1; fi


# Build the installer
if ( test -e /usr/local/bin/packagesbuild ) then
	echo "Building the installer..."
	/usr/local/bin/packagesbuild GPGTools.pkgproj
else
	echo "ERROR: You need the Application \"Packages\"!"
	echo "get it at http://s.sudre.free.fr/Software/Packages.html"
	exit 1
fi

# remove files from earlier execution
rm build/GPGTools-$(date "+%Y%m%d").dmg

tar xfvj resources/template.dmg.tar.bz2

hdiutil attach "template.dmg" -noautoopen -quiet -mountpoint "gpgtools_diskimage"


# Copy the relevant files
ditto --rsrc build/GPGTools.mpkg gpgtools_diskimage/Install\ GPGTools.mpkg
ditto --rsrc Uninstall_GPGTools.app gpgtools_diskimage/Uninstall\ GPGTools.app
cp images/gpgtoolsdmg.icns gpgtools_diskimage/.VolumeIcon.icns
cp images/dmg_background.png gpgtools_diskimage/.background/dmg_background.png
./scripts/setfileicon images/trash.icns gpgtools_diskimage/Uninstall\ GPGTools.app
./scripts/setfileicon images/installer.icns gpgtools_diskimage/Install\ GPGTools.mpkg

# get the name of the dvice to detatch it
dmg_device=` hdiutil info | grep "gpgtools_diskimage" | awk '{print $1}' `

hdiutil detach $dmg_device -quiet -force

hdiutil convert "template.dmg" -quiet -format UDZO -imagekey zlib-level=9 -o "build/GPGTools-$(date "+%Y%m%d").dmg"

# remove the extracted template
rm template.dmg

gpg2 --detach-sign -u 76D78F0500D026C4 build/GPGTools-$(date "+%Y%m%d").dmg
open build/GPGTools-$(date "+%Y%m%d").dmg
