#!/usr/bin/env bash

###############################################################################
# GPGTools complete build script.
#
# @author   Alex
# @goal     Invoke this script and have a complete GPGTools.dmg at the end
# @todo     To much to write down
###############################################################################


###############################################################################
# config / global variables
###############################################################################
_hasWriteAccess=1 # or 1
_readURL="https://github.com/"
_writeURL="git@github.com:"
_basePath="GPGTools/"
_baseFolder="build/"
[[ $_hasWriteAccess = 1 ]] && _baseURL="$_writeURL" || _baseURL="$_readURL"


###############################################################################
# functions
###############################################################################
buildProject () {
  # config
  projectName="$1"
  projectBranch="$2"
  projectPath="${projectName}/"
  projectRepo="${_baseURL}${_basePath}${projectName}"
  logFile="${projectName}.log"

  # checkout
  echo " * Working on ${projectRepo}..."
  (
  if [ ! -d "${projectName}" ]; then 
    git clone --recursive --depth 1 -b "${projectBranch}" "${projectRepo}"  
  fi
  
  cd "${projectPath}"
  make update compile
  ) > "${logFile}" 2>&1
  
  if [ "$?" != "0" ]; then echo "ERROR! See ${logFile}."; fi
}

buildInstaller () {
  echo " * To be done: Working on GPGTools Installer..."
  echo "   * Copying files..."
  echo "   * Creating installer..."
  echo "   * Creating final DMG..."
}

###############################################################################
# main
###############################################################################
mkdir -p "${_baseFolder}"; cd "${_baseFolder}"
buildProject "pinentry-mac" "master"
buildProject "Libmacgpg" "master"
buildProject "GPGPreferences" "master"
buildProject "GPGServices" "master"
buildProject "GPGKeychainAccess" "master"
buildProject "GPGMail" "master"
buildProject "MacGPG2" "homebrew"

#todo: create installer based on the binaries above