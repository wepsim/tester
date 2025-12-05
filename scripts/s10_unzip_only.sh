#!/bin/bash
#set -x

#
#   Copyright 2015-2026 Felix Garcia Carballeira, Alejandro Calderon Mateos, Javier Prieto Cepeda, Saul Alonso Monsalve
#
#   This file is part of WepSIM (https://wepsim.github.io/wepsim/)
#
#   WepSIM is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   WepSIM is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Lesser General Public License for more details.
#
#   You should have received a copy of the GNU Lesser General Public License
#   along with WepSIM.  If not, see <http://www.gnu.org/licenses/>.
#

# Welcome
echo ""
echo "s10_unzip"
echo "---------"
echo ""

# Test parameters...
if [ $# -lt 1 ]; then
     echo "  Version: v1.5"
     echo "    Usage:"
     echo "    * $0 <list (one per line) of .zip files (without .zip) to uncompress: p2-88.in>"
     echo "    * $0 <group_90_bundle_from_aula_global_as_download_all_submissions>.zip"
     echo ""
     exit
fi

# Setup group bundle (in case of .zip file)...
ARG_TYPE=$(file -b $1)
if [ "$ARG_TYPE" != "ASCII text" ]; then
    echo " => First, unzip group bundle."
    echo "    Please check if there several persons of the same group that submitted the lab."
    echo "    In this case, please rename each submission to latter check which one is the last one."
    BASE_DIR=$(echo $1 | sed 's/\.zip//g')
    unzip -ojad $BASE_DIR $1
    ls -1 $BASE_DIR/ | sed 's/\.zip//g' | sort | uniq > $BASE_DIR".in"
else
    BASE_DIR=$(echo $1 | sed 's/\.in//g')
fi

# Unzip each submission withing the group...
echo " => Unzip each submission..."
while IFS= read -r A; do

    echo "$A"
    unzip -a -u -d "$BASE_DIR/${A}" "$BASE_DIR/${A}.zip"

    if [ -d "$BASE_DIR/$A/${A}" ]; then
         mv "$BASE_DIR/$A/${A}/"* "$BASE_DIR/${A}"
         rmdir "$BASE_DIR/$A/${A}"
    fi

done < $BASE_DIR".in"

# Done.
echo ""
echo "unzip done."
echo ""

