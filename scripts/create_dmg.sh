#!/bin/bash
#
# This script creates a DMG  for GPGTools
#
# (c) by Felix Co & Alexander Willner
#

pushd "$(dirname "$0")/.." > /dev/null


#config ------------------------------------------------------------------
releaseDir="build"
appName="GPGTools.mpkg"
rmName="Uninstall_GPGTools.app"
appPath="$releaseDir/$appName"
dmgName="GPGTools-$(date "+%Y%m%d").dmg"
dmgPath="build/$dmgName"
dmgTempPath="build/temp.dmg"
volumeName="GPGTools"
#-------------------------------------------------------------------------


#-------------------------------------------------------------------------
if ( ! test -e Makefile ) then
	echo "Wrong directory..."
	exit 1
fi
#-------------------------------------------------------------------------


#-------------------------------------------------------------------------
echo "Compiling GPGServices...";
mkdir -p payload/gpgservices
#(cd ../GPGServices && git pull && make && cd - && rm -rf payload/gpgservices/GPGServices.service && cp -r ../GPGServices/build/Release/GPGServices.service payload/gpgservices/) > build.log 2>&1
if [ ! "$?" == "0" ]; then echo "ERROR. Look at build.log"; exit 1; fi
echo "Compiling GPGKeychainAccess..."
mkdir -p payload/keychain_access
#(cd ../GPGKeychainAccess && git pull && make && cd - && rm -rf payload/keychain_access/Applications/GPG\ Keychain\ Access.app && cp -r ../GPGKeychainAccess/build/Release/GPG\ Keychain\ Access.app payload/keychain_access/Applications/)  > build.log 2>&1
if [ ! "$?" == "0" ]; then echo "ERROR. Look at build.log"; exit 1; fi
echo "Compiling GPGMail...";
mkdir -p payload/gpgmail
#(cd ../GPGMail/GPGMail && git pull && make && cd - && rm -rf payload/gpgmail/GPGMail.mailbundle && cp -r ../GPGMail/GPGMail/build/Release/GPGMail.mailbundle payload/gpgmail/)  > build.log 2>&1
if [ ! "$?" == "0" ]; then echo "ERROR. Look at build.log"; exit 1; fi
#-------------------------------------------------------------------------


#-------------------------------------------------------------------------
if ( test -e /usr/local/bin/packagesbuild ) then
	echo "Building the installer..."
#	/usr/local/bin/packagesbuild GPGTools.pkgproj
else
	echo "ERROR: You need the Application \"Packages\"!"
	echo "get it at http://s.sudre.free.fr/Software/Packages.html"
	exit 1
fi
#-------------------------------------------------------------------------


#-------------------------------------------------------------------------
echo "Removing old files..."
rm -f "$dmgTempPath"
rm -f "$dmgPath"
rm -rf "build/dmgTemp"

echo "Creating temp folder..."
mkdir build/dmgTemp

echo "Copying files..."
mkdir build/dmgTemp/.background
cp images/dmg_background.png build/dmgTemp/.background/Background.png
cp images/gpgtoolsdmg.icns build/dmgTemp/.VolumeIcon.icns
cp -PR "$appPath" build/dmgTemp/
cp -PR "$rmName" build/dmgTemp/

echo "Creating DMG..."
hdiutil create -scrub -quiet -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW -srcfolder build/dmgTemp -volname "$volumeName" "$dmgTempPath"
mountInfo=$(hdiutil attach -readwrite -noverify "$dmgTempPath")
device=$(echo "$mountInfo" | head -1 | cut -d " " -f 1)
mountPoint=$(echo "$mountInfo" | tail -1 | sed -En 's/([^	]+[	]+){2}//p')

echo "Setting attributes..."
	SetFile -a C "$mountPoint"

	osascript >/dev/null << EOT1
	tell application "Finder"
		tell disk "$volumeName"
			open
			set viewOptions to icon view options of container window
			set current view of container window to icon view
			set toolbar visible of container window to false
			set statusbar visible of container window to false
			set bounds of container window to {400, 200, 580 + 400, 320 + 200}
			set arrangement of viewOptions to not arranged
			set icon size of viewOptions to 64
			set text size of viewOptions to 13
			set background picture of viewOptions to file ".background:Background.png"

			set position of item "$appName" of container window to {160, 220}
			set position of item "$rmName" of container window to {390, 220}
			update without registering applications
			close
		end tell
	end tell
EOT1

./scripts/setfileicon images/trash.icns "$mountPoint/$rmName"
./scripts/setfileicon images/installer.icns "$mountPoint/$appName"
chmod -Rf +r,go-w "$mountPoint"


echo "Cleanup..."
rm -r "$mountPoint/.Trashes" "$mountPoint/.fseventsd"
hdiutil detach -quiet "$mountPoint"
hdiutil convert "$dmgTempPath" -quiet -format UDZO -imagekey zlib-level=9 -o "$dmgPath"
rm -rf build/dmgTemp
rm -f "$dmgTempPath"

echo "Signing..."
gpg2 -bau 76D78F0500D026C4 "$dmgPath"

echo -e "DMG created\n\n"

open "$dmgPath"

popd > /dev/null
