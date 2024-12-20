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


echo ""
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo "       WepSIM Tester on Docker (v1.0) "
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo ""
echo " + Example of checking the submission file p2-90.zip from the group 90:"
echo ""
echo "     ./s10_tests.sh      tests/tests.in                        ;: a. To prepare the test output to compare with"
echo "     ./s10_unzip.sh  p2-90.zip                                 ;: b. To unzip all submitted files"
echo "     ls -1 p2-90/ | sed 's/\.zip//g' | sort | uniq > p2-90.in  ;: c. To get the list of submitted files to check"
echo "     ./s20_check.sh  ES  tests/tests.in   p2-90.in             ;: d. To check this 90 group"
echo ""
echo " + For checking several groups:"
echo "   + After (a), and after (b) and (c) for each group:"
echo ""
echo "     ./s20_check.sh  ES  tests/tests.in   p2-80.in"
echo "     ./s20_check.sh  ES  tests/tests.in   p2-50.in"
echo "     ./s20_check.sh  ES  tests/tests.in   p2-81.in"
echo "     ./s20_check.sh  ES  tests/tests.in   p2-82.in"
echo "     ./s20_check.sh  ES  tests/tests.in   p2-83.in"
echo "     ./s20_check.sh  EN  tests/tests.in   p2-88.in"
echo "     ./s20_check.sh  EN  tests/tests.in   p2-89.in"
echo ""
echo " + If any submitted work <xxxxx_yyyyy> from group <zz> needs to be modified (*),"
echo "   then backup the original submission first in the *ORIGINAL* subdirectory:"
echo ""
echo "     mkdir -p                           p2-<zz>/<xxxxx_yyyyy>/ORIGINAL"
echo "     cp    -a p2-<zz>/<xxxxx_yyyyy>/*   p2-<zz>/<xxxxx_yyyyy>/ORIGINAL"
echo ""
echo "   (*) For example:"
echo "    * If file names are not OK (p2-report.pdf, ej2_microcode.txt.txt, etc.)"
echo "    * If fetch has to be remove from the submitted microcode."
echo "    * Etc."
echo ""
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo ""

