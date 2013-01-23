#!/usr/bin/env bash

###############################################################################
# GPGTools complete build script.
#
# @author   Alex, Lukas
# @goal     Invoke this script and have a complete GPGTools.dmg at the end
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
	createFlags="$3"
	createDMG=$(echo "$createFlags" | grep "d" &>/dev/null && echo "1" || echo "0")
	createPKG=$(echo "$createFlags" | grep "p" &>/dev/null && echo "1" || echo "0")
	projectAltName="$4"
	
	(
	  checkoutProject "${projectName}" "${projectBranch}" hasUpdates
	  if [ "$hasUpdates" == "1" ]; then
		# Remove the build folder so the project is compiled from scratch.
		rm -rf "${_baseFolder}/${projectName}_${projectBranch}/build"
	  fi
	  if [ -z "$createPKG" ] || [ -z "$createDMG" ]; then
	  	compile
	  fi
	  if [ "$createPKG" == "1" ]; then
		createPackage "${projectName}" "${projectBranch}" "${projectAltName}"
	  fi
	  if [ "$createDMG" == "1" ]; then
		createDMG
	  fi
	  exit 0
	)
}

buildProject () {
  # config
  projectName="$1"
  projectBranch="$2"
  createFlags="$3"
  
  projectAltName="$4"
  projectDir="${projectName}_${projectBranch}";
  projectRepo="${_baseURL}${_basePath}${projectName}"
  logFile="${projectDir}.log"

  echo " * Working on ${projectBranch} branch under ${projectRepo}..."
  if [ "$VERBOSE" != "1" ]; then
 	_buildProject "$projectName" "$projectBranch" "$createFlags" "$projectAltName" > "${logFile}" 2>&1
  else
	_buildProject "$projectName" "$projectBranch" "$createFlags" "$projectAltName"
  fi

  if [ "$?" != "0" ]; then
		echo "ERROR! See ${logFile}."
		tail -n 20 "${logFile}"
		exit 2
  fi
}

compile() {
	make
}

createPackage() {
	projectName="$1"
	projectBranch="$2"
	projectAltName=$(test -z "$3" && echo ${projectName} || echo "$3")
	projectAltName="${projectAltName:-projectName}"
	
	make pkg-core
	# Prepare for final installer
	CORE_PKG_DIR=${_corePackageFolder} ALT_NAME=$projectAltName make pkg-prepare-for-installer
}

createDMG () {
    CORE_PKG_DIR=${_corePackageFolder} make dmg
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

buildInstaller () {
  logFile="installer.log"
  
  buildProject "GPGTools_Installer" "dev"

  echo " * Working on GPGTools Installer..."
  cd "GPGTools_Installer_dev"
  
  echo "   * Creating installer package..."
  createInstallerPackage

  echo "   * Creating final DMG..."
  createDMG > "${logFile}" 2>&1
}

createInstallerPackage () {
 	CORE_PKG_DIR=${_corePackageFolder} make pkg
}

###############################################################################
# main
###############################################################################
checkEnvironment
createWorkingDirectory

# Build project can be instructed to build a package (p), build
# a dmg (d) or build both (pd) or none (don't set the 3rd argument).
# Build all tools except GPGMail in parallel.
(buildProject "GPGPreferences" "dev" "p") &
(buildProject "GPGServices" "dev" "p") &
(buildProject "GPGKeychainAccess" "dev" "p") &
(buildProject "Libmacgpg" "dev" "p") &
(
	buildProject "GPGMail" "dev" "p" "GPGMail_10.7" && \
 	buildProject "GPGMail" "experimental" "p" "GPGMail_10.7+" && \
 	buildProject "GPGMail" "snow_leopard" "p" "GPGMail_10.6"
) &
(buildProject "MacGPG2" "dev" "p") &

wait

echo "All projects finished building. Creating GPGTools Installer."

buildInstaller
