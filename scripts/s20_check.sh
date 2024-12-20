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

function general_report_print_header {
    RPH_LIST_I=$(cat $1)
    RPH_NUMBER_I=$(wc -l $1 | cut -f1 -d" " )
    echo "<html>"                                                    > $REPORT_HTML
    echo ""                                                         >> $REPORT_HTML
    echo "<head>"                                                   >> $REPORT_HTML
    echo "<style>"                                                  >> $REPORT_HTML
    echo "table {"                                                  >> $REPORT_HTML
    echo " border-collapse: collapse;"                              >> $REPORT_HTML
    echo "}"                                                        >> $REPORT_HTML
    echo "table, th, td {"                                          >> $REPORT_HTML
    echo " border: 1px solid black;"                                >> $REPORT_HTML
    echo "}"                                                        >> $REPORT_HTML
    echo "</style>"                                                 >> $REPORT_HTML
    echo "</head>"                                                  >> $REPORT_HTML
    echo ""                                                         >> $REPORT_HTML
    echo "<body>"                                                   >> $REPORT_HTML
    echo "<table border=1 width=100%>"                              >> $REPORT_HTML
    echo "<tr>"                                                     >> $REPORT_HTML
    echo "<td align=center rowspan=2>Summary</td>"                  >> $REPORT_HTML
    echo "<td align=center rowspan=2>Group</td>"                    >> $REPORT_HTML
    echo "<td align=center rowspan=2>NIA</td>"                      >> $REPORT_HTML
    echo "<td align=center rowspan=2>OK submission</td>"            >> $REPORT_HTML
    echo "<td align=center rowspan=2>OK field type</td>"            >> $REPORT_HTML
    echo "<td align=center colspan=$RPH_NUMBER_I>Exercise 1</td>"   >> $REPORT_HTML
    echo "</tr>"                                                    >> $REPORT_HTML
    echo ""                                                         >> $REPORT_HTML
    echo "<tr>"                                                     >> $REPORT_HTML
    # ej1
    for I in $RPH_LIST_I; do
    echo "<td align=center><a href=tests/mp-$I>$I</a></td>"         >> $REPORT_HTML
    done
    echo "</tr>"                                                    >> $REPORT_HTML
    echo ""                                                         >> $REPORT_HTML
}

function general_report_print_footer {
    echo "</table>"                                                 >> $REPORT_HTML
    echo "</body>"                                                  >> $REPORT_HTML
    echo ""                                                         >> $REPORT_HTML
    echo "</html>"                                                  >> $REPORT_HTML
}

function convert_to_ascii {
    #
    # iconv: convert UTF-8 to ASCII just in case no text ASCII-text was submitted:
    #

    touch $2/e1_checkpoint_ascii.txt
    touch $2/e1_mc_ascii.txt

    if [ -f $1/e1_checkpoint.txt ]; then
             #/usr/bin/iconv --from-code UTF-8 --to-code US-ASCII -c $1/e1_checkpoint.txt > $2/e1_checkpoint_ascii.txt
             cp $1/e1_checkpoint.txt $2/e1_checkpoint_ascii.txt
             ./wepsim.sh --maxi 10000 -a show-microcode -c $2/e1_checkpoint_ascii.txt > $2/e1_mc_ascii.txt
    fi
}

function html_print_pre {
        O=""
        O+="<html>\n"
        O+="<head><title>$I</title></head>\n"
        O+="<body>\n"
        O+="<pre>\n"
        O+=$(cat $1 | grep -v screen)
        O+="</pre>\n"
        O+="</body>\n"
        O+="</html>\n"
        printf "%b" "$O" > $2
}


# Welcome
echo ""
echo "s20_check"
echo "---------"

# Test parameters...
if [ $# -lt 1 ]; then
     echo "  Version: v2.5"
     echo "    Usage: $0       <test list file (one per line)> <list (one per line) of directories to check>"
     echo "  Example: $0       tests/tests.in                p2-81.in"
     echo "  Example: $0       tests/tests.in                p2-82.in"
     echo ""
     exit
fi


# Setup workspace...
FNAME_I=$1
LIST_I=$(cat $1)
TEST_DIR=$(dirname $1)

LIST_A=$(cat $2)
BASE_DIR=$(echo $2 | sed 's/\.in//g')

REPORT_DIR="report-"$BASE_DIR
REPORT_HTML="report-"$BASE_DIR".html"


# Report: dir + file
rm    -fr $REPORT_DIR
mkdir -p  $REPORT_DIR
rm    -fr $REPORT_HTML
general_report_print_header $FNAME_I

#
for A in $LIST_A; do

    echo  ""
    echo  "$A: ......................................... "

    # Initialize
    mkdir -p $REPORT_DIR/$A
    mkdir -p $REPORT_DIR/$A/output

    E1_CHECKPOINT_NAME=e1_checkpoint.txt
    REPORT=report.pdf
    AUTHORS=authors.txt

    U=""

    ## entregado
    if [ -f $BASE_DIR/$A/$E1_CHECKPOINT_NAME -a \
         -f $BASE_DIR/$A/$REPORT             -a \
         -f $BASE_DIR/$A/$AUTHORS ]; then
       EOK=1
    else
       EOK=0
    fi

    # si no est'a entregado correctamente entonces avisar
    if [ $EOK -eq 0 ]; then
         ls -1 $BASE_DIR/$A/ | sed 's/^/ (please check filenames) /g'
    fi

    # procesar conversiones utf-8 <-> ascii <-> ...
    convert_to_ascii $BASE_DIR/$A $REPORT_DIR/$A

    echo  " ........... EJ-1: "
    ## ej1

       # build test-mC-e1
       cat $TEST_DIR/check-mc-part1         > $REPORT_DIR/$A/test-mc-e1.txt
       cat $REPORT_DIR/$A/e1_mc_ascii.txt  >> $REPORT_DIR/$A/test-mc-e1.txt
       cat $TEST_DIR/check-mc-part2        >> $REPORT_DIR/$A/test-mc-e1.txt

for I in $LIST_I; do

       # build test-mP-e1
       cat $TEST_DIR/check-mp-part1   $TEST_DIR/mp-$I   > $REPORT_DIR/$A/test-mp-$I.txt

       # check test-mC-e1 test-mP-e1
        ./wepsim.sh --maxi 10000 -a check -m ep -f $REPORT_DIR/$A/test-mc-e1.txt -s $REPORT_DIR/$A/test-mp-$I.txt -r $TEST_DIR/base/out-$I.txt  > $REPORT_DIR/$A/output/out-$I.txt
 echo " ./wepsim.sh --maxi 10000 -a check -m ep -f $REPORT_DIR/$A/test-mc-e1.txt -s $REPORT_DIR/$A/test-mp-$I.txt -r $TEST_DIR/base/out-$I.txt  > $REPORT_DIR/$A/output/out-$I.txt"

       # score
       SCORE=0
       if grep -q "OK" $REPORT_DIR/$A/output/out-$I.txt; then
           SCORE=1
       fi

       # report
       IT=$REPORT_DIR/$A/output/out-$I.txt
       OT=$REPORT_DIR/$A/output/out-$I.html
       html_print_pre $IT $OT

       U+="<td align=center><a href=$REPORT_DIR/$A/output/out-$I.html>$SCORE</a></td>\n"

done
    ## /ej1


    ## Individual Group Report:
    if [ -d "$BASE_DIR/$A/ORIGINAL" ]; then
        EOK=0
    fi

    O=""
    O+="<html>\n"
    O+="<head><title>$A</title></head>\n"
    O+="<body>\n"
    O+="<h1>$A</h1>\n"
    #
    O+="<h2>Exercise 1</h2>\n"
for I in $LIST_I; do
    O+="<h3>$I</h3>\n"
    O+="<pre>\n"
    O+=$(cat $REPORT_DIR/$A/output/out-$I.txt | grep -v screen)
    O+="</pre>\n"
    O+="<br>\n"
done
    #
    O+="<h2>Others</h2>\n"
    if [ -d "$BASE_DIR/$A/ORIGINAL" ]; then
    O+="<h2>Diferencias con archivo entregado <a href=../../$BASE_DIR/$A/ORIGINAL/e1_checkpoint.txt>e1_checkpoint.txt</a></h2>\n"
    O+="<pre>\n"
    O+=$(diff $REPORT_DIR/$A/e1_mc_ascii.txt $BASE_DIR/$A/ORIGINAL/e1_checkpoint.txt)
    O+="</pre>\n"
    fi
    O+="</body>\n"
    O+="</html>\n"
    printf "%b" "$O" > $REPORT_DIR/$A/$A.html

    ## general report
    O=""
    AA=$(echo $A | sed 's/_/ /g')
    for AAI in $AA; do
        O+="<tr>\n"
        O+="<td align=center>$A</td>\n"
        O+="<td align=center>$AAI</td>\n"
        O+="<td align=center><a href=$BASE_DIR/$A/>$EOK</a></td>\n"
        O+="$U"
        O+="</tr>\n"
    done
    printf "%b" "$O" >> $REPORT_HTML

done

#
general_report_print_footer

echo ""
echo "$REPORT_HTML generated."
echo ""

