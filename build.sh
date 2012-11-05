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

cpForInstaller () {
  rm -rf "build/payload/$2"; mkdir -p "build/payload/$2"; cp -R "../$1" "build/payload/$2"
}

buildInstaller () {
  echo " * Working on GPGTools Installer..."
  cd "GPGTools_Installer_master"
  
  echo "   * Copying files..."
  # todo: read makefile config and use these variables to copy the files
  src="GPGKeychainAccess_master/build/Release/GPG Keychain Access.app"
  dst="gka/"
  cpForInstaller "${src}" "${dst}"
  src="GPGMail_snow_leopard/build/Release/GPGMail.mailbundle"
  dst="gpgmail106/private/tmp/GPGMail_Installation/"
  cpForInstaller "${src}" "${dst}"
  src="GPGPreferences_master/build/Release/GPGPreferences.prefPane"
  dst="gpgtoolspreferences/"
  cpForInstaller "${src}" "${dst}"
  src="GPGMail_experimental/build/GPGMail.mpkg"
  dst="gpgmail107/"
  cpForInstaller "${src}" "${dst}"
  src="GPGServices_master/build/GPGServices.mpkg/Contents/Packages/GPGServices.pkg"
  dst="gpgservices"
  cpForInstaller "${src}" "${dst}"
  src="MacGPG2_homebrew/build/MacGPG2.mpkg/Contents/Packages/MacGPG2.pkg"
  dst="MacGPG2"
  cpForInstaller "${src}" "${dst}"
  
  echo "   * Creating installer..."
  packagesbuild GPGTools.pkgproj

  echo "   * Creating final DMG..."
  ./Dependencies/GPGTools_Core/scripts/create_dmg.sh auto buildbot
}

###############################################################################
# main
###############################################################################
checkEnvironment
mkdir -p "${_baseFolder}"; cd "${_baseFolder}"
#buildProject "pinentry-mac" "master" "0"
#buildProject "Libmacgpg" "master" "0"
buildProject "GPGPreferences" "master" "1"
buildProject "GPGServices" "master" "1"
buildProject "GPGKeychainAccess" "master" "1"
buildProject "GPGMail" "experimental" "1"
buildProject "GPGMail" "snow_leopard" "1"
buildProject "MacGPG2" "homebrew" "1"
buildProject "GPGTools_Installer" "master" "0"
buildInstaller
