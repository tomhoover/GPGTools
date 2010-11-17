#!/bin/bash
# 
# This script creates a DMG  for GPGTools
#
# (c) by Felix Co
#
# edited by Roman Zechmeister
#

dmgPath=build/GPGTools-$(date "+%Y%m%d").dmg


# remove files from earlier execution
rm -f $dmgPath
rm -f ${dmgPath}.zip
rm -rf build/dmgTemp


# Create temp folder
mkdir build/dmgTemp


# Copy dmg resources
cp dmgResources/DS_Store build/dmgTemp/.DS_Store
mkdir build/dmgTemp/.background
cp dmgResources/Background.png build/dmgTemp/.background/Background.png


# Copy the relevant files
ditto build/GPGTools.mpkg build/dmgTemp/GPGTools.mpkg
ditto Uninstall_GPGTools.app build/dmgTemp/Uninstall_GPGTools.app


# Create DMG
hdiutil create -srcfolder build/dmgTemp -quiet -volname GPGTools $dmgPath 

# Create ZIP
zip -j ${dmgPath}.zip $dmgPath


# Remove temp
rm -rf build/dmgTemp

