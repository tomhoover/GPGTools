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

createWorkingDirectory () {
  mkdir -p "${_baseFolder}"; cd "${_baseFolder}"
}

buildProject () {
  # config
  projectName="$1"
  projectBranch="$2"
  createDMG="$3"
  projectDir="${projectName}_${projectBranch}";
  projectRepo="${_baseURL}${_basePath}${projectName}"
  logFile="${projectDir}.log"

  echo " * Working on ${projectBranch} branch under ${projectRepo}..."
  (
  checkoutProject "${projectName}" "${projectBranch}"
  [ "${createDMG}" == "1" ] && createDMG
  exit 0
  ) > "${logFile}" 2>&1
  
  [ "$?" != "0" ] && echo "ERROR! See ${logFile}." && exit 2
}

checkoutProject () {
  # config
  projectName="$1"
  projectBranch="$2"
  projectDir="${projectName}_${projectBranch}";
  projectRepo="${_baseURL}${_basePath}${projectName}"

  # checkout
  if [ ! -d "${projectDir}" ]; then 
    git clone --recursive --depth 1 -b "${projectBranch}" "${projectRepo}" "${projectDir}"
  fi
  
  cd "${projectDir}"
  git pull; [ "$?" != "0" ] && exit 1
}

createDMG () {
    make dmg
}

buildInstaller () {
  logFile="installer.log"
  
  echo " * Working on GPGTools Installer..."
  cd "GPGTools_Installer_master"
  
  echo "   * Copying files..."
  copyInstallerBinaries

  echo "   * Creating final DMG..."
  createDMG \
  > "${logFile}" 2>&1
}

copyInstallerBinaries () {
  # todo: read makefile config and use these variables to copy the files
  src="GPGKeychainAccess_master/build/Release/GPG Keychain Access.app"
  dst="gka/"
  copyAndOverwrite "${src}" "${dst}"

  src="GPGMail_snow_leopard/build/Release/GPGMail.mailbundle"
  dst="gpgmail106/private/tmp/GPGMail_Installation/"
  copyAndOverwrite "${src}" "${dst}"

  src="GPGMail_master/build/GPGMail.mpkg"
  dst="gpgmail107/"
  copyAndOverwrite "${src}" "${dst}"

  src="GPGMail_experimental/build/GPGMail.mpkg"
  dst="gpgmail108/"
  copyAndOverwrite "${src}" "${dst}"

  src="GPGPreferences_master/build/Release/GPGPreferences.prefPane"
  dst="gpgtoolspreferences/"
  copyAndOverwrite "${src}" "${dst}"

  src="GPGServices_master/build/GPGServices.mpkg/Contents/Packages/GPGServices.pkg"
  dst="gpgservices"
  copyAndOverwrite "${src}" "${dst}"

  src="MacGPG2_dev/build/MacGPG2_Core.pkg"
  dst="MacGPG2"
  copyAndOverwrite "${src}" "${dst}"
}

copyAndOverwrite () {
  rm -rf "build/payload/$2"; mkdir -p "build/payload/$2"; cp -R "../$1" "build/payload/$2"
}

###############################################################################
# main
###############################################################################
checkEnvironment
createWorkingDirectory
#buildProject "pinentry-mac" "dev" "0"
#buildProject "Libmacgpg" "dev" "0"
#buildProject "GPGPreferences" "dev" "1"
#buildProject "GPGServices" "dev" "1"
#buildProject "GPGKeychainAccess" "dev" "1"
#buildProject "GPGMail" "master" "1"
#buildProject "GPGMail" "dev" "1"
#buildProject "GPGMail_SL" "dev" "1"
#buildProject "MacGPG2" "dev" "1"
#buildProject "GPGTools_Installer" "dev" "0"

buildProject "GPGPreferences" "master" "1"
buildProject "GPGServices" "master" "1"
buildProject "GPGKeychainAccess" "master" "1"
buildProject "GPGMail" "master" "1"
buildProject "GPGMail" "experimental" "1"
buildProject "GPGMail" "snow_leopard" "1"
buildProject "MacGPG2" "dev" "1"
buildProject "GPGTools_Installer" "master" "0"

buildInstaller
