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


function e1_get_microcode {
      BASE_DIR_A=$1
    REPORT_DIR_A=$2

    touch ${REPORT_DIR_A}/e1_checkpoint_ascii.txt
    touch ${REPORT_DIR_A}/e1_mc_ascii.txt

    # if no file -> error
    if [ ! -f ${BASE_DIR_A}/e1_checkpoint.txt ]; then
         return 0
    fi

    # convert UTF8 to ASCII
    ##/usr/bin/iconv --from-code UTF-8 --to-code US-ASCII -c ${BASE_DIR_A}/e1_checkpoint.txt > ${REPORT_DIR_A}/e1_checkpoint_ascii.txt
    cp ${BASE_DIR_A}/e1_checkpoint.txt ${REPORT_DIR_A}/e1_checkpoint_ascii.txt

    # get microcode from checkpoint
    ./wepsim.sh -a show-microcode -c ${REPORT_DIR_A}/e1_checkpoint_ascii.txt > ${REPORT_DIR_A}/e1_mc_ascii.txt

    # if syntax error -> error
    if grep -q "SyntaxError" ${REPORT_DIR_A}/e1_mc_ascii.txt; then
       return 0
    fi

    # rename base microcode instructions (rdcycle, in, out, ...)...
    mv  ${REPORT_DIR_A}/e1_mc_ascii.txt ${REPORT_DIR_A}/e1_mc_ascii_step1_submitted.txt
    sed -e 's/rdcycle /tmp_rdcycle /g' \
        -e 's/in /tmp_in /g' \
        -e 's/out /tmp_out /g' \
        -e 's/bck2ftch/bck2ftchX/g' \
        ${REPORT_DIR_A}/e1_mc_ascii_step1_submitted.txt > ${REPORT_DIR_A}/e1_mc_ascii_step2_clean.txt
     cp ${REPORT_DIR_A}/e1_mc_ascii_step2_clean.txt       ${REPORT_DIR_A}/e1_mc_ascii.txt

    return 1
}


# Welcome
echo ""
echo "s20_check_e1"
echo "------------"

# 1) Test parameters...
if [ $# -lt 1 ]; then
     echo "  Version: v3.0"
     echo "    Usage: $0 <test list file>  <list of directories to check>"
     echo " Examples: $0 tests/tests.in    p2-81.in"
     echo "           $0 tests/tests.in    p2-88.in"
     echo ""
     echo "  test list file  ::= file with the list of test (one per line)"
     echo "  submission list ::= file with the list of directories to check (one per line)"
     echo ""
     exit
fi


# 2) Setup workspace...
 FNAME_I=$1
  LIST_I=$(cat $1)
TEST_DIR=$(dirname $1)

LIST_A=$(cat $2)
BASE_DIR=$(echo $2 | sed 's/\.in//g')

REPORT_DIR="report-"$BASE_DIR
REPORT_CSV="report-"$BASE_DIR"-e1.csv"
REPORT=report.pdf
AUTHORS=authors.txt
E1_CHECKPOINT_NAME=e1_checkpoint.txt

# Report: dir + file
rm    -fr $REPORT_DIR
mkdir -p  $REPORT_DIR
rm    -fr $REPORT_CSV


# 3) For each submission and for each person in submission...
for A in $LIST_A; do

    echo  ""
    echo  "$A: ................................... EJ1 ...................................... "

    mkdir -p $REPORT_DIR/$A
    mkdir -p $REPORT_DIR/$A/output


    # 3.1) Check submitted OK
    ## check ok naming
    if [ -f $BASE_DIR/$A/$E1_CHECKPOINT_NAME -a \
         -f $BASE_DIR/$A/$REPORT             -a \
         -f $BASE_DIR/$A/$AUTHORS ]; then
       EOK=1
    else
       EOK=0
    fi

    if [ $EOK -eq 0 ]; then
         ls -1 $BASE_DIR/$A/ | sed 's/^/ (please check filenames) /g'
    fi

    ## checking input file,  convert utf-8 <-> ascii, etc.
    e1_get_microcode $BASE_DIR/$A $REPORT_DIR/$A
    if [ $? -eq 0 ]; then
       EOK=0
    fi

    if [ $EOK -eq 0 ]; then
         ls -1 $BASE_DIR/$A/ | sed 's/^/ (please check file formats) /g'
    fi

    ## if (p2-yy/<xxxxx_yyyyy>/ORIGINAL) => something was wrong submitted, then solved
    if [ -d "$BASE_DIR/$A/ORIGINAL" ]; then
        EOK=0
    fi


    # 3.2) Check test results
    C=""
    U=""

    # build test-mC-e1
    cat $TEST_DIR/check-mc-part1         > $REPORT_DIR/$A/test-mc-e1.txt
    cat $REPORT_DIR/$A/e1_mc_ascii.txt  >> $REPORT_DIR/$A/test-mc-e1.txt
    cat $TEST_DIR/check-mc-part2        >> $REPORT_DIR/$A/test-mc-e1.txt

    for I in $LIST_I; do

           # build test-mP-e1
           cat $TEST_DIR/check-mp-part1   $TEST_DIR/mp-$I   > $REPORT_DIR/$A/test-mp-$I.txt

           # check test-mC-e1 test-mP-e1
     echo " ./wepsim.sh --maxi 10000 -a check -m ep -f $REPORT_DIR/$A/test-mc-e1.txt -s $REPORT_DIR/$A/test-mp-$I.txt -r $TEST_DIR/base/out-$I.txt  > $REPORT_DIR/$A/output/out-$I.txt"
            ./wepsim.sh --maxi 10000 -a check -m ep -f $REPORT_DIR/$A/test-mc-e1.txt -s $REPORT_DIR/$A/test-mp-$I.txt -r $TEST_DIR/base/out-$I.txt  > $REPORT_DIR/$A/output/out-$I.txt

           # score
           SCORE=0
           if grep -q "OK" $REPORT_DIR/$A/output/out-$I.txt; then
               SCORE=1
           fi

	   C+="Score $I;"
           U+="\t$SCORE;"

    done

    ## 3.3) General report as CSV
    O=""
    AA=$(echo $A | sed 's/_/ /g')
    for AAI in $AA; do
        H=""
	H+="Person;"
        O+="$AAI;"
	H+="Group;"
        O+="$A;"
	H+="Summary;"
        O+="\t$REPORT_DIR/$A/$A.html;"
	H+="mcode;"
        O+="$REPORT_DIR/$A/e1_mc_ascii.txt;"
	H+="Submission;"
        O+="\t$BASE_DIR/$A/;"
	H+="Submission code;"
        O+="$EOK;"

        H+="$C\n"
        O+="$U\n"
    done

    printf "%b" "$H" >> $REPORT_CSV
    printf "%b" "$O" >> $REPORT_CSV

done

echo ""
echo "$REPORT_CSV generated."
echo ""

