#!/bin/bash
#set -x

#
#  Copyright 2015-2026 Felix Garcia Carballeira, Alejandro Calderon Mateos, Diego Alonso Camarmas
#
#  This file is part of WepSIM (https://wepsim.github.io/wepsim/)
#
#  WepSIM is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  WepSIM is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with WepSIM.  If not, see <http://www.gnu.org/licenses/>.
#


# 0) Check arguments
if [ $# -eq 0 ]; then
    echo ""
    echo " Usage:"
    echo "  $0 <install path>"
    echo ""
    echo " Example:"
    echo "  $0 /opt/wepsim"
    echo ""
    exit
fi

INSTALL_PATH=$1
VER_NAME=2.3.6


# 1) Install base software
echo "Try to install utilities..."
sudo aptitude install zip unzip p7zip p7zip-full -y

# 2) Install nodejs
echo "Try to install nodejs..."
curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
rm -fr nodesource_setup.sh
sudo apt-get install nodejs -y

# 3) Install WepSIM
pushd . >& /dev/null
cd /tmp
wget -N https://github.com/wepsim/wepsim/releases/download/v${VER_NAME}/wepsim-${VER_NAME}.zip
unzip  wepsim-${VER_NAME}.zip
mkdir -p                   ${INSTALL_PATH}
rm -fr                     ${INSTALL_PATH}
mv     wepsim-${VER_NAME}  ${INSTALL_PATH}

cd $INSTALL_PATH
cp wepsim-classic.html wepsim.html
npm install terser jq jshint yargs clear inquirer@8.2.6 fuzzy inquirer-command-prompt inquirer-autocomplete-prompt@1
npm audit fix >& /dev/null
popd >& /dev/null

