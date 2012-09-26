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
_hasWriteAccess=0 # 0 or 1
_readURL="https://github.com/"
_writeURL="git@github.com:"
_basePath="GPGTools/"
_baseFolder="build/"
[[ $_hasWriteAccess = 1 ]] && _baseURL="$_writeURL" || _baseURL="$_readURL"



###############################################################################
# functions
###############################################################################
checkEnvironment () {
  if [ ! -e /usr/local/bin/packagesbuild ]; then
    echo "ERROR: You need the Application \"Packages\"!\nget it at http://s.sudre.free.fr/Software/Packages.html"
    exit 1;
  fi
}


buildProject () {
  # config
  projectName="$1"
  projectBranch="$2"
  projectInstaller="$3"
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
  [ "$?" != "0" ] && exit 1
  
  if [ "${projectInstaller}" == "1" ]; then
    ./Dependencies/GPGTools_Core/scripts/create_dmg.sh auto buildbot
    [ "$?" != "0" ] && exit 2
  fi
  
  exit 0
  ) > "${logFile}" 2>&1
  
  if [ "$?" != "0" ]; then
    echo "ERROR! See ${logFile}.";
  fi
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
checkEnvironment
mkdir -p "${_baseFolder}"; cd "${_baseFolder}"
buildProject "pinentry-mac" "master"
buildProject "Libmacgpg" "master"
buildProject "GPGPreferences" "master" "1"
buildProject "GPGServices" "master" "1"
buildProject "GPGKeychainAccess" "master" "1"
buildProject "GPGMail" "master" "1"
buildProject "MacGPG2" "homebrew" "1"

buildInstaller