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
_baseFolder="`pwd`/build/"
_corePackageFolder="${_baseFolder}/core-packages"
[[ $_hasWriteAccess = 1 ]] && _baseURL="$_writeURL" || _baseURL="$_readURL"

VERBOSE=0
if [ "$1" == "verbose" ]; then
	VERBOSE=1
fi

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

_buildProject () {
	projectName="$1"
	projectBranch="$2"
	createDMG="$3"
	projectAltName="$4"
	
	(
	  checkoutProject "${projectName}" "${projectBranch}" hasUpdates
	  echo "updates: $hasUpdates"
	  if [ "$hasUpdates" == "1" ]; then
		# Remove the build folder so the project is compiled from scratch.
		rm -rf "${_baseFolder}/${projectName}_${projectBranch}/build"
	  fi
	  compileAndMakePackage "${projectName}" "${projectBranch}" "${projectAltName}"
	  [ "${createDMG}" == "1" ] && createDMG
	  exit 0
	)
}

buildProject () {
  # config
  projectName="$1"
  projectBranch="$2"
  createDMG="$3"
  projectAltName="$4"
  projectDir="${projectName}_${projectBranch}";
  projectRepo="${_baseURL}${_basePath}${projectName}"
  logFile="${projectDir}.log"

  echo " * Working on ${projectBranch} branch under ${projectRepo}..."
  if [ "$VERBOSE" != "1" ]; then
 	_buildProject "$projectName" "$projectBranch" "$createDMG" "$projectAltName" > "${logFile}" 2>&1
  else
	_buildProject "$projectName" "$projectBranch" "$createDMG" "$projectAltName"
  fi

  if [ "$?" != "0" ]; then
		echo "ERROR! See ${logFile}."
		tail -n 20 "${logFile}"
		exit 2
  fi
}

compileAndMakePackage() {
	projectName="$1"
	projectBranch="$2"
	projectAltName=$(test -z "$3" && echo ${projectName} || echo "$3")
	projectAltName="${projectAltName:-projectName}"
	
	make pkg
	# Prepare for final installer
	CORE_PKG_DIR=${_corePackageFolder} ALT_NAME=$projectAltName make pkg-prepare-for-installer
}

checkoutProject () {
  # config
  projectName="$1"
  projectBranch="$2"
  local __resultvar=$3
  projectDir="${projectName}_${projectBranch}";
  projectRepo="${_baseURL}${_basePath}${projectName}"

  # checkout
  if [ ! -d "${projectDir}" ]; then 
    git clone --recursive --depth 1 -b "${projectBranch}" "${projectRepo}" "${projectDir}"
  fi
  
  cd "${projectDir}"
  # Check if there are updates in remote branch.
  current=`git rev-parse HEAD`
  git pull; [ "$?" != "0" ] && exit 1
  local diff="$(git diff $current..)"
  eval $__resultvar="'$(test -z "$diff" && echo "0" || echo "1")'"
}

createDMG () {
    CORE_PKG_DIR=${_corePackageFolder} make dmg
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
 	CORE_PKG_DIR=${_corePackageFolder} make pkg
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

buildProject "GPGPreferences" "dev" "1"
buildProject "GPGServices" "dev" "1"
buildProject "GPGKeychainAccess" "dev" "1"
buildProject "GPGMail" "dev" "1" "GPGMail_10.7"
buildProject "GPGMail" "experimental" "1" "GPGMail_10.7+"
buildProject "GPGMail" "snow_leopard" "1" "GPGMail_10.6"
buildProject "Libmacgpg" "dev" "1"
buildProject "MacGPG2" "dev" "1"
buildProject "GPGTools_Installer" "master" "0"

buildInstaller
