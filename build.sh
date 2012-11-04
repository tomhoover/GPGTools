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


checkout () {
  # config
  projectName="$1"
  projectBranch="$2"
  projectInstaller="$3"
  projectDir="${projectName}_${projectBranch}";
  projectPath="${projectName}/"
  projectRepo="${_baseURL}${_basePath}${projectName}"
  logFile="${projectName}.log"

  # checkout
  if [ ! -d "${projectDir}" ]; then 
    git clone --recursive --depth 1 -b "${projectBranch}" "${projectRepo}" "${projectDir}"
  fi
  
  cd "${projectDir}"
  make update; [ "$?" != "0" ] && exit 1
}

buildProject () {
  # config
  projectName="$1"
  projectBranch="$2"
  projectInstaller="$3"
  projectDir="${projectName}_${projectBranch}";
  projectPath="${projectName}/"
  projectRepo="${_baseURL}${_basePath}${projectName}"
  logFile="${projectDir}.log"

  echo " * Working on ${projectBranch} branch at ${projectRepo}..."
  (

  # checkout
  checkout "$1" "$2" "$3"

  if [ "${projectInstaller}" == "1" ]; then
     make compile; [ "$?" != "0" ] && exit 1
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
  echo " * Working on GPGTools Installer..."
  cd "build/GPGTools_Installer"
  echo "   * Copying files..."
  # todo: read makefile config and use these variables to copy the files
  mkdir -p "build/"
  echo "   * Creating installer..."
  echo "   * Creating final DMG..."
}

###############################################################################
# main
###############################################################################
checkEnvironment
mkdir -p "${_baseFolder}"; cd "${_baseFolder}"
buildProject "pinentry-mac" "master" "0"
buildProject "Libmacgpg" "master" "0"
buildProject "GPGPreferences" "master" "1"
buildProject "GPGServices" "master" "1"
buildProject "GPGKeychainAccess" "master" "1"
buildProject "GPGMail" "experimental" "1"
buildProject "GPGMail" "snow_leopard" "1"
#buildProject "MacGPG2" "homebrew" "1"
buildProject "GPGTools_Installer" "master" "0"