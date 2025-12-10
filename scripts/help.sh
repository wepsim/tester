#!/bin/bash
#set -x

#
#   Copyright 2015-2025 Felix Garcia Carballeira, Alejandro Calderon Mateos, Diego Alonso Camarmas
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
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo "  Help summary for the WepSIM Tester "
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo ""
echo "  = Help based on example based on a imaginary group 90, being p2-90.zip the associated submission file."
echo "  = Expected current working directory is the results directory ('cd /work/results' if you need it)"
echo ""
echo "  + To prepare the testbed (usually only the first time):"
echo ""
echo "     ./s10_tests.sh    tests/tests.in                      ;: b. To prepare the test output to compare with"
echo "     ./s10_unzip.sh    p2-90.zip                           ;: c. To unzip all submitted files"
echo ""
echo "  + To check the group 90:"
echo ""
echo "     ./s40_checker.sh  tests/tests.in  p2-90.in               ;: a.1 To check exercises and make report for group 90"
echo "     ./s40_checker.sh  tests/tests.in  p2-90.in  order-90.in  ;: a.1 To check exercises and make report for group 90"
echo ""
echo "  + To read the associated report:"
echo ""
echo "     lynx report-p2-90.html                                   ;: b.1 To open the associated report (lynx/firefox/...)"
echo "     python3 -m http.server 8000 &                            ;: b.2 HTTP server to read remotely the results"
echo ""
echo "  + While some submitted work <xxxxx_yyyyy> from group 90 needs to be modified, then:"
echo ""
echo "    * Backup the original submission first in the *ORIGINAL* subdirectory:"
echo "       pushd ."
echo "       cd p2-90/<xxxxx_yyyyy>/"
echo "       mkdir -p      ORIGINAL"
echo "       cp    -a  *   ORIGINAL/"
echo ""
echo "    * Make the amendments:"
echo "      * If file names are not OK (p2-report.pdf, ej2_microcode.txt.txt, etc.)"
echo "          mv ej2_microcode.txt.txt e2_checkpoint.txt"
echo "      * If e1_checkpoint.txt is not a checkpoint, but the microcode as text:"
echo "          touch /tmp/empty.asm"
echo "          mv    e1_checkpoint.txt   e1_mcode.txt"
echo "          ./wepsim.sh -a build-checkpoint -m ep -f e1_mcode.txt -s /tmp/empty.asm > e1_checkpoint.txt"
echo "      * If fetch has to be remove from the submitted microcode."
echo "      * Etc."
echo ""
echo "    * Check again:"
echo "       popd"
echo "       ./s40_checker.sh   tests/tests.in   p2-90.in"
echo "       lynx report-p2-90.html"
echo ""
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo ""

