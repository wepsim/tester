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
if [ $# -lt 2 ]; then
    echo ""
    echo " Usage:"
    echo "  $0 <base path> <wepsim path> <install path>"
    echo "  * NOTE: please you must avoid install_path be the same than the base_path"
    echo ""
    echo " Example:"
    echo "  $0 /work /opt/wepsim /work/results"
    echo ""
    exit
fi

SOURCE_PATH=$1
WEPSIM_PATH=$2
INSTALL_PATH=$3


# 1) To prepare the results directory
mkdir -p                $INSTALL_PATH

# copy tests, scripts, and submissions
pushd . >& /dev/null
cd $SOURCE_PATH
cp -a ./tests           $INSTALL_PATH/tests
cp -a ./scripts/*       $INSTALL_PATH/
cp -a ./submissions/*   $INSTALL_PATH/
popd >& /dev/null

# copy wepsim and rebuild the wepsim.sh link
pushd . >& /dev/null
cd $INSTALL_PATH
cp -a $WEPSIM_PATH       ./wepsim
rm -fr                   ./wepsim.sh
ln -s ./wepsim/wepsim.sh ./wepsim.sh
popd >& /dev/null

