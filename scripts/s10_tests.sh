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

#
echo ""
echo "s10_tests"
echo "---------"
echo ""

# Test parameters...
if [ $# -lt 1 ]; then
     echo "  Version: v2.2"
     echo "    Usage: $0 <list (one per line) of tests: tests/tests.in>"
     echo ""
     exit
fi

#
LIST_I=$(cat $1)
BASE_DIR=$(dirname $1)

#
mkdir -p $BASE_DIR/base
cat $BASE_DIR/check-mc-part1 $BASE_DIR/check-mc $BASE_DIR/check-mc-part2 > $BASE_DIR/base/mc.txt

for I in $LIST_I; do

    cat $BASE_DIR/check-mp-part1 $BASE_DIR/mp-$I > $BASE_DIR/base/mp-$I.txt

    echo "./wepsim.sh --maxi 10000 -a run -m ep -f $BASE_DIR/base/mc.txt -s $BASE_DIR/base/mp-$I.txt | grep -v screen > $BASE_DIR/base/out-$I.txt"
          ./wepsim.sh --maxi 10000 -a run -m ep -f $BASE_DIR/base/mc.txt -s $BASE_DIR/base/mp-$I.txt | grep -v screen > $BASE_DIR/base/out-$I.txt

done

#
./wepsim.sh -a build-checkpoint -m ep -f $BASE_DIR/base/mc.txt -s $BASE_DIR/mp-ej2.txt > $BASE_DIR/check-checkpoint-riscv.txt

#
echo ""
echo "Reference built."
echo ""

