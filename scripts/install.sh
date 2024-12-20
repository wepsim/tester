#!/bin/bash
set -x

# Install dependencies
apt-get update && apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        aptitude apt-utils \
        zlib1g-dev ca-certificates pkg-config \
        software-properties-common gpg-agent \
        curl libcurl3-dev \
        wget rsync \
        sudo lshw \
        vim lynx git \
        \
        nasm \
        man-db doxygen \
        htop lsof \
        \
        inetutils-ping \
        netcat \
        nmap net-tools hping3 \
        iftop nload \
        \
        kmod \
        \
        libtool \
	rpcbind \
	libjson-c-dev \
        jq \
        \
        zip unzip p7zip p7zip-full unrar p7zip-rar \
        \
        yamllint \
        ubuntu-restricted-extras \
        imagemagick \
        && \
    apt-get clean


# nodejs: Install
curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
rm -fr nodesource_setup.sh
sudo apt-get install nodejs -y

# WepSIM: Install
mkdir -p /opt/ && \
cd       /opt/ && \
wget -N https://github.com/wepsim/wepsim/releases/download/v2.3.3/wepsim-2.3.3.zip && \
unzip wepsim-2.3.3.zip && \
rm -fr               /opt/wepsim && \
mv /opt/wepsim-2.3.3 /opt/wepsim

cd /opt/wepsim && \
cp wepsim-classic.html wepsim.html && \
npm install terser jq jshint yargs clear inquirer fuzzy inquirer-command-prompt inquirer-autocomplete-prompt

