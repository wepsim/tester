#!/bin/bash
#set -x

#
#   Copyright 2015-2025 Felix Garcia Carballeira, Alejandro Calderon Mateos, Javier Prieto Cepeda, Saul Alonso Monsalve
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
echo "r10_split"
echo "---------"
echo ""

# Test parameters...
if [ $# -lt 1 ]; then
     echo "  Version: v1.0"
     echo "    Usage: $0 <list (one per line) of directories with checkpoint to split: p2-88.in>"
     echo ""
     exit
fi

# Setup workspace...
LIST_A=$(cat $1)
BASE_DIR=$(echo $1 | sed 's/\.in//g')

#
for A in $LIST_A; do

    CHECKPOINT1=$BASE_DIR/$A/e1_checkpoint.txt
    CHECKPOINT2=$BASE_DIR/$A/e2_checkpoint.txt
    WORK_DIR_NAME=$BASE_DIR/$A/CHECKER/
    mkdir -p $WORK_DIR_NAME

    echo " $A ......................... "
    echo "	./wepsim.sh -a show-microcode --checkpoint $CHECKPOINT1 > $WORK_DIR_NAME/e1_microcode.txt"
    echo "	./wepsim.sh -a show-assembly  --checkpoint $CHECKPOINT2 > $WORK_DIR_NAME/e2_assembly.txt"

    ./wepsim.sh -a show-microcode --checkpoint $CHECKPOINT1 > $WORK_DIR_NAME/e1_microcode.txt
    ./wepsim.sh -a show-assembly  --checkpoint $CHECKPOINT2 > $WORK_DIR_NAME/e2_assembly.txt

done

echo ""
echo " Done."
echo ""

