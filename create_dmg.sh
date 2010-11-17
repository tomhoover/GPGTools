#!/bin/bash
# 
# This script creates a DMG  for GPGTools
#
# (c) by Felix Co
#

# remove files from earlier execution
rm build/GPGTools-$(date "+%Y%m%d").dmg
rm build/GPGTools-$(date "+%Y%m%d").dmg.zip

tar xfvj template.dmg.tar.bz2

hdiutil attach "template.dmg" -noautoopen -quiet -mountpoint "gpgtools_diskimage"


# Copy the relevant files
ditto --rsrc build/GPGTools.mpkg gpgtools_diskimage/GPGTools.mpkg
ditto --rsrc Uninstall_GPGTools.app gpgtools_diskimage/Uninstall_GPGTools.app

# get the name of the dvice to detatch it
dmg_device=` hdiutil info | grep "gpgtools_diskimage" | awk '{print $1}' `

hdiutil detach $dmg_device -quiet -force

hdiutil convert "template.dmg" -quiet -format UDZO -imagekey zlib-level=9 -o "build/GPGTools-$(date "+%Y%m%d").dmg"

zip -j build/GPGTools-$(date "+%Y%m%d").dmg.zip build/GPGTools-$(date "+%Y%m%d").dmg

# remove the extracted template
rm template.dmg
