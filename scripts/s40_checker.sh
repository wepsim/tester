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
echo "s40_checker"
echo "-----------"

# 1) Test parameters...
if [ $# -lt 1 ]; then
     echo "  Version: v1.0"
     echo "    Usage: $0 <test list file>  <submission list>"
     echo " Examples: $0  tests/tests.in    p2-81.in"
     echo "           $0  tests/tests.in    p2-88.in"
     echo ""
     echo "  test list file  ::= file with the list of test (one per line)"
     echo "  submission list ::= file with the list of directories to check (one per line)"
     echo ""

# TODO: next version with reordering
#
#     echo "  Version: v2.0"
#     echo "    Usage: $0 <test list file>  <submission list>  <ID order to use>"
#     echo " Examples: $0  tests/tests.in    p2-81.in           order-81.in"
#     echo "           $0  tests/tests.in    p2-88.in           order-81.in"
#     echo ""
#     echo "  test list file  ::= file with the list of test (one per line)"
#     echo "  submission list ::= file with the list of directories to check (one per line)"
#     echo "  ID order to use ::= file with the ordered list of student (one per line)"
#     echo ""
     exit
fi

# 2) Setup workspace...
TEST_LIST=$1
SUBM_LIST=$2
ORDER_LIST=$3

# 3) Checks...
./s20_check_e1.sh  $TEST_LIST       $SUBM_LIST
./s20_check_e2.sh  $TEST_LIST       $SUBM_LIST
./s30_report.sh    $TEST_LIST       $SUBM_LIST

