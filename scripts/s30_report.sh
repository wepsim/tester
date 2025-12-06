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
    echo ""                                                         >> $REPORT_HTML
    echo "<table border=1 width=100%>"                              >> $REPORT_HTML

    echo "<tr>"                                                     >> $REPORT_HTML
    echo "<td align=center rowspan=2>Summary</td>"                  >> $REPORT_HTML
    echo "<td align=center rowspan=2>Group</td>"                    >> $REPORT_HTML
    echo "<td align=center rowspan=2>NIA</td>"                      >> $REPORT_HTML
    echo "<td align=center rowspan=2>OK submission</td>"            >> $REPORT_HTML
    echo "<td align=center rowspan=2>OK field type</td>"            >> $REPORT_HTML
    echo "<td align=center colspan=$RPH_NUMBER_I>Exercise 1</td>"   >> $REPORT_HTML
    echo "<td align=center colspan=1>Exercise 2</td>"               >> $REPORT_HTML
    echo "</tr>"                                                    >> $REPORT_HTML

    echo "<tr>"                                                     >> $REPORT_HTML
    # ej1
    for I in $RPH_LIST_I; do
    cp  tests/mp-$I  tests/mp-${I}".txt"
    echo "<td align=center><a href=tests/mp-${I}.txt>$I</a></td>"   >> $REPORT_HTML
    done
    # ej2
    echo "<td align=center>execution</td>"                          >> $REPORT_HTML
    echo "</tr>"                                                    >> $REPORT_HTML
    echo ""                                                         >> $REPORT_HTML
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

function get_data_from_csv {
    declare -n VALS_ARR="$1"
    REPORT_CSV=$2

    IFS=';' read -r -a H <<< $(head -1 $REPORT_CSV)
    IFS=';' read -r -a L <<< $(grep $A $REPORT_CSV | head -1)

    NE=$(echo "${#L[@]}")

    for I in $(seq 1 $NE); do
	K=${H[$I]}
	V=${L[$I]}
	if [ ! -z "${K}" ]; then
             VALS_ARR[$K]="$V"
	fi
    done
}


# Welcome
echo ""
echo "s30_report"
echo "----------"

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
  REPORT_HTML="report-"$BASE_DIR".html"
REPORT_CSV_E1="report-"$BASE_DIR"-e1.csv"
REPORT_CSV_E2="report-"$BASE_DIR"-e2.csv"


# 3) For each submission and for each person in submission...
## report header
rm -fr $REPORT_HTML
general_report_print_header $FNAME_I

# report data
for A in $LIST_A; do

    echo  ""
    echo  "$A: ......................................... "

    ## get CSV data
    declare -A VALS
    VALS["Group"]=$A

    get_data_from_csv VALS ${REPORT_CSV_E1}
    get_data_from_csv VALS ${REPORT_CSV_E2}

    ## Associated test scores:
    U=""
    for I in $LIST_I; do

        # Associated test report:
        IT=$REPORT_DIR/$A/output/out-$I.txt
        OT=$REPORT_DIR/$A/output/out-$I.html
        html_print_pre $IT $OT

        U+="<td align=center><a href=\"$REPORT_DIR/$A/output/out-$I.html\">"${VALS["Score $I"]}"</a></td>\n"

    done

    ## General report:
    O=""
    AA=$(echo $A | sed 's/_/ /g')
    for AAI in $AA; do

        O+="<tr>\n"
        O+="<td align=center> <a href=\""${VALS["Summary"]}"\">$AAI</a>, <a href="${VALS["mcode"]}">mcode</a>, <a href=\""${VALS["Assembly"]}"\">asm</a> </td>\n"
        O+="<td align=center>$A</td>\n"
        O+="<td align=center>$AAI</td>\n"
        O+="<td align=center><a href=\""${VALS["Submission"]}"\">"${VALS["Submission code"]}"</a></td>\n"
        O+="<td align=center><a href=\""${VALS["Fields file"]}"\">"${VALS["Fields code"]}"</a></td>\n"
        O+="$U"
        O+="<td align=center><a href=\"$REPORT_DIR/$A/output/out-e2-t1.txt\">"${VALS["Score e2-t1"]}"</a></td>\n"
        O+="</tr>\n"

    done
    printf "%b" "$O" >> $REPORT_HTML

    ## Individual Group Report:
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
    O+="<h2>Exercise 2</h2>\n"
    O+="<h3>Execution</h3>\n"
    O+="<pre>\n"
    O+=$(cat $REPORT_DIR/$A/output/out-e2-t1.txt)
    O+="</pre>\n"
    O+="<br>\n"
    #
    O+="<h2>Others</h2>\n"
    if [ -d "$BASE_DIR/$A/ORIGINAL" ]; then
    O+="<h2>Diferencias con archivo entregado <a href=../../$BASE_DIR/$A/ORIGINAL/e1_checkpoint.txt>e1_checkpoint.txt</a></h2>\n"
    O+="<pre>\n"
    O+=$(diff $REPORT_DIR/$A/e1_mc_ascii.txt $BASE_DIR/$A/ORIGINAL/e1_checkpoint.txt)
    O+="</pre>\n"
    O+="<h2>Diferencias con archivo entregado <a href=../../$BASE_DIR/$A/ORIGINAL/e2_checkpoint.txt>e2_checkpoint.txt</a></h2>\n"
    O+="<pre>\n"
    O+=$(diff $BASE_DIR/$A/e2_checkpoint.txt $BASE_DIR/$A/ORIGINAL/e2_checkpoint.txt)
    O+="</pre>\n"
    fi
    O+="</body>\n"
    O+="</html>\n"
    printf "%b" "$O" > $REPORT_DIR/$A/$A.html

done

# footer
echo "</table>"                         >> $REPORT_HTML
echo "</body>"                          >> $REPORT_HTML
echo ""                                 >> $REPORT_HTML
echo "</html>"                          >> $REPORT_HTML

# ok
echo ""
echo "$REPORT_HTML generated."
echo ""

