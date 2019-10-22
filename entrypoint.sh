#!/bin/bash

set -exo

SCRIPTDIR="/home/pfred/scripts"
SCRIPTS="pfred \
         BioPerl-1.6.1 \
         oligowalk \
         ensemblapi \
         bowtie"

BOWTIEL="a b c d e"

# TODO: Check if website is working

WEB=https://github.com/pfred/pfred-docker/releases/download/v1.0-alpha

echo "Setting up environment..."

# Get Tomcat

if [ ! -d "/home/pfred/tomcat" ]; then
    echo "Downloading Tomcat from port 9090"
    wget $WEB/tomcat.tar.gz
    for f in *.tar.gz; do tar -xvf "$f"; done
    rm *.tar.gz
fi

# Get scripts

cd $SCRIPTDIR

for dir in $SCRIPTS
do
    if [ ! -d $SCRIPTDIR/$dir ]; then
        echo "Downloading $dir from github"
        if [ $dir == "bowtie" ]; then
            for letter in $BOWTIEL
            do
                wget $WEB/$dir.tar.gz.parta$letter
            done
            cat bowtie.tar.gz.parta* > bowtie.tar.gz
            rm *.tar.gz.parta*
        else
            wget $WEB/$dir.tar.gz
        fi

        tar -xvf $dir.tar.gz
        rm *.tar.gz
    fi
done

chmod +x pfred/*
ls
cat /home/pfred/setup_env.sh >> /root/.bashrc && source /root/.bashrc
startup.sh

# Keep container running

while true; do sleep 1000; done
