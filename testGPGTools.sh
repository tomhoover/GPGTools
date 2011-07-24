#!/bin/bash
################################################################################
# Test all GPGTools sub projects.
#
# @prereq   OS X >= 10.5, Xcode >= 3, and SDK 10.5
# @tested   OS X Lion 10.7.0
# @see      http://gpgtools.org
# @version  2011-07-24
################################################################################


# config #######################################################################
root="`pwd`/build";
logfile="/tmp/gpgtools.log";
projects=( \
"Libmacgpg" \
"GPGKeychainAccess" \
"GPGServices" \
"GPGTools_Preferences" \
"GPGMail" \
"MacGPG1" \
"MacGPG2" \
)
################################################################################


# functions ####################################################################
function testEnvironment {
    echo " * Testing environment...";
    echo -n "   * 10.5 SDK: ";
    if [ -d "/Developer/SDKs/MacOSX10.5.sdk" ]; then echo "OK"; else echo "FAIL!"; fi
    echo -n "   * git: ";
    if [ "`which git`" != "" ]; then echo "OK"; else echo "FAIL!"; fi
    echo -n "   * make: ";
    if [ "`which make`" != "" ]; then echo "OK"; else echo "FAIL!"; fi
    echo -n "   * Xcode: ";
    if [ "`which xcodebuild`" != "" ]; then echo "OK"; else echo "FAIL!"; fi
}

function evalResult {
    if [ "$1" == "0" ]; then
        echo "OK";
    else
        echo "FAIL ($1)! See '$2' for details.";
    fi
}

function downloadProject {
    _name="$1";
    _url="git://github.com/GPGTools/$_name.git";
    : > $logfile.$_name
    echo -n "   * Downloading '$_name'...";
    if [ -d "$_name" ]; then
        pushd . > /dev/null
        cd "$_name";
        git pull origin master > $logfile.$_name 2>&1;
        popd > /dev/null
    else
        git clone --recursive --depth 1 $_url $_name > $logfile.$_name 2>&1;
    fi
    evalResult $? $logfile.$_name
}

function compileProject {
    echo -n "   * Building '$_name'...";
    make clean compile >> $logfile.$_name 2>&1;
    evalResult $? $logfile.$_name
}

function testProject {
    echo -n "   * Testing '$_name'...";
    make test >> $logfile.$_name 2>&1;
    evalResult $? $logfile.$_name
}

function workonProject {
    _name="$1";
    echo " * Working on '$_name'...";
    : > $logfile.$_name
    mkdir -p $root; cd $root;
    downloadProject $_name; cd $_name;
    compileProject $_name;
    testProject $_name;
}
################################################################################

# main #########################################################################
echo "Testing GPGTools...";
testEnvironment
for project in "${projects[@]}"; do
    workonProject $project
done
################################################################################
