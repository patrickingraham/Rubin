#!/usr/bin/env bash
# This script should be sourced to clone and setup the packages needed to
# configure the Nublado environment to use methods from
# rapid_analysis, such as bestEffortISR
# it's required to run the latiss_align_and_take_sequence script
# and the latiss_cwfs script
# This script is optimized for the AuxTel run of 2021-03-09

source ${LOADSTACK}
# eups distrib install -t w_2021_10 lsst_distrib

# If running from Nublado instance than only use the following
setup lsst_distrib

# Modify the following line to point to where you want to clone
# and setup the repositories
REPOS=$HOME"/develop/"

echo 'Repositories will cloned and setup in the directory:'$REPOS"\n"
mkdir -p ${REPOS}
# Check if folders are already present before installing
printf 'Setting up lsst-dm/Spectractor \n'
if [ -d $REPOS"/Spectractor" ]
then
    printf "Directory "$REPOS"/Spectractor exists. Skipping package install and leaving original.\n"
else
    cd $REPOS
    git clone https://github.com/lsst-dm/Spectractor.git
    cd Spectractor
    git checkout tickets/DM-28773
    git pull
    pip install -r requirements.txt
    pip install -e .
fi

printf '\nSetting up lsst-dm/atmospec \n'
if [ -d $REPOS"/atmospec" ]
then
    printf "Directory "$REPOS"/atmospec exists. Skipping package install and leaving original.\n"
else
    cd $REPOS
    git clone https://github.com/lsst-dm/atmospec.git
    cd atmospec
    setup -j -r .
    git fetch --all
    git checkout tickets/DM-26719
    scons opt=3 -j 4
fi

printf '\nSetting up lsst-sitcom/rapid_analysis \n'
if [ -d $REPOS"/rapid_analysis" ]
then
    printf "Directory "$REPOS"/rapid_analysis exists. Skipping package install and leaving original.\n"
else
    cd $REPOS
    git clone https://github.com/lsst-sitcom/rapid_analysis.git
    cd rapid_analysis
    setup -j -r .
    scons opt=3 -j 4
    git fetch --all
    git checkout tickets/DM-21412
fi

printf '\nSetting up bxin/cwfs \n'
if [ -d $REPOS"/cwfs" ]
then
    printf "Directory "$REPOS"/cwfs exists. Skipping package install and leaving original.\n"
else
    cd $REPOS
    git clone git@github.com:bxin/cwfs.git
    cd cwfs
    git fetch --all
    setup -j -r .
    scons
fi

# Create screen output reminding people to update their .user_setups and refresh kernel
printf "==== ATTENTION ====\n"
printf "ADD THE FOLLOWING TO YOUR ~/notebooks/.user_setups file \n"
printf "then be sure to restart every notebook kernel \n"
printf ""
printf "setup -j rapid_analysis -r "$REPOS"rapid_analysis \n"
printf "setup -j atmospec -r "$REPOS"atmospec \n"
printf "setup -j cwfs -r "$REPOS"cwfs \n"
