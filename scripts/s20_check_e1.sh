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


function convert_to_ascii {
    touch $2/e1_checkpoint_ascii.txt
    touch $2/e1_mc_ascii.txt
    touch $2/e2_checkpoint_ascii.txt

    EOK=1
    if [ -f $1/e1_checkpoint.txt ]; then
             #/usr/bin/iconv --from-code UTF-8 --to-code US-ASCII -c $1/e1_checkpoint.txt > $2/e1_checkpoint_ascii.txt
             cp $1/e1_checkpoint.txt $2/e1_checkpoint_ascii.txt

             ./wepsim.sh --maxi 10000 -a show-microcode -c $2/e1_checkpoint_ascii.txt > $2/e1_mc_ascii.txt
             if grep -q "SyntaxError" $2/e1_mc_ascii.txt; then
                 EOK=0
             fi
    fi

    if [ -f $1/e2_checkpoint.txt ]; then
             ## iconv: convert UTF-8 to ASCII just in case no text ASCII-text was submitted:
             #/usr/bin/iconv --from-code UTF-8 --to-code US-ASCII -c $1/e2_checkpoint.txt > $2/e2_checkpoint_ascii.txt
             cp $1/e2_checkpoint.txt $2/e2_checkpoint_ascii.txt
    fi

    return $EOK
}


# Welcome
echo ""
echo "s20_check_ej1"
echo "-------------"

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
REPORT_CSV="report-"$BASE_DIR".csv"

# Report: dir + file
rm    -fr $REPORT_DIR
mkdir -p  $REPORT_DIR
rm    -fr $REPORT_CSV

# 3) General_report print header
  RPH_LIST_I=$(cat $FNAME_I)
RPH_NUMBER_I=$(wc -l $FNAME_I | cut -f1 -d" ")

O=""
O+="Summary;"
O+="Group;"
O+="NIA;"
O+="OK submission;"
O+="OK field type;"
for I in $RPH_LIST_I; do
    O+="$I,tests/mp-$I;"
done
printf "%b" "$O\n" >> $REPORT_CSV

# 4) Check each submission and add grades for each person in submission
for A in $LIST_A; do

    echo  ""
    echo  "$A: ... EJ1 ...................................... "

    # Initialize
    mkdir -p $REPORT_DIR/$A
    mkdir -p $REPORT_DIR/$A/output

    E1_CHECKPOINT_NAME=e1_checkpoint.txt
    E2_CHECKPOINT_NAME=e2_checkpoint.txt
    REPORT=report.pdf
    AUTHORS=authors.txt

    # Initial cheks

    ## entregado nombres correctos
    if [ -f $BASE_DIR/$A/$E1_CHECKPOINT_NAME -a \
         -f $BASE_DIR/$A/$E2_CHECKPOINT_NAME -a \
         -f $BASE_DIR/$A/$REPORT             -a \
         -f $BASE_DIR/$A/$AUTHORS ]; then
       EOK=1
    else
       EOK=0
    fi

    # si nombres no est'an entregado correctamente entonces avisar
    if [ $EOK -eq 0 ]; then
         ls -1 $BASE_DIR/$A/ | sed 's/^/ (please check filenames) /g'
    fi

    # procesar conversiones utf-8 <-> ascii <-> ...
    convert_to_ascii $BASE_DIR/$A $REPORT_DIR/$A

    # si checkpoint no est'a entregado correctamente entonces avisar
    if [ $? -eq 0 ]; then
         ls -1 $BASE_DIR/$A/ | sed 's/^/ (please check filenames) /g'
    fi

    # Initialize checks
    U=""

    # remove base microcode...
    mv  $REPORT_DIR/$A/e1_mc_ascii.txt $REPORT_DIR/$A/e1_mc_ascii_step1_submitted.txt
    sed -e 's/rdcycle /tmp_rdcycle /g' \
        -e 's/in /tmp_in /g' \
        -e 's/out /tmp_out /g' \
        -e 's/bck2ftch/bck2ftchX/g' \
        $REPORT_DIR/$A/e1_mc_ascii_step1_submitted.txt > $REPORT_DIR/$A/e1_mc_ascii_step2_clean.txt
     cp $REPORT_DIR/$A/e1_mc_ascii_step2_clean.txt       $REPORT_DIR/$A/e1_mc_ascii.txt

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

           U+="$REPORT_DIR/$A/output/out-$I,$SCORE;\t"

    done

    # if (p2-yy/<xxxxx_yyyyy>/ORIGINAL) => something was wrong submitted, then solved
    if [ -d "$BASE_DIR/$A/ORIGINAL" ]; then
        EOK=0
    fi

    ## General report
    O=""
    AA=$(echo $A | sed 's/_/ /g')
    for AAI in $AA; do
        O+="$REPORT_DIR/$A/$A.html,$AAI,$REPORT_DIR/$A/e1_mc_ascii.txt,mcode,$REPORT_DIR/$A/e2_assembly.txt,asm;\t"
        O+="$A;\t"
        O+="$AAI;\t"
        O+="$BASE_DIR/$A/,$EOK;\t"
        O+="$REPORT_DIR/$A/e2-mc-fields-imm.txt,$FIELD_SCORE;\t"
        O+="$U"
    done
    printf "%b" "$O\n" >> $REPORT_CSV

done

#
echo "" >> $REPORT_CSV

echo ""
echo "$REPORT_CSV generated."
echo ""

