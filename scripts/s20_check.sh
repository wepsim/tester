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
    echo "<html>"                                                > $REPORT_HTML
    echo ""                                                 >> $REPORT_HTML
    echo "<head>"                                           >> $REPORT_HTML
    echo "<style>"                                          >> $REPORT_HTML
    echo "table {"                                          >> $REPORT_HTML
    echo " border-collapse: collapse;"                      >> $REPORT_HTML
    echo "}"                                                >> $REPORT_HTML
    echo "table, th, td {"                                  >> $REPORT_HTML
    echo " border: 1px solid black;"                        >> $REPORT_HTML
    echo "}"                                                >> $REPORT_HTML
    echo "</style>"                                         >> $REPORT_HTML
    echo "</head>"                                          >> $REPORT_HTML
    echo ""                                                 >> $REPORT_HTML
    echo "<body>"                                                   >> $REPORT_HTML
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
    echo ""                                                         >> $REPORT_HTML
    echo "<tr>"                                                     >> $REPORT_HTML
    # ej1
    for I in $RPH_LIST_I; do
    echo "<td align=center><a href=tests/mp-$I>$I</a></td>"      >> $REPORT_HTML
    done
    # ej2
    echo "<td align=center>execution</td>"                          >> $REPORT_HTML
    echo "</tr>"                                                    >> $REPORT_HTML
    echo ""                                                         >> $REPORT_HTML
}

function general_report_print_footer {
    echo "</table>"                                                 >> $REPORT_HTML
    echo "</body>"                          >> $REPORT_HTML
    echo ""                                 >> $REPORT_HTML
    echo "</html>"                          >> $REPORT_HTML
}

function convert_to_ascii {
    #
    # iconv: convert UTF-8 to ASCII just in case no text ASCII-text was submitted:
    #

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
             #/usr/bin/iconv --from-code UTF-8 --to-code US-ASCII -c $1/e2_checkpoint.txt > $2/e2_checkpoint_ascii.txt
             cp $1/e2_checkpoint.txt $2/e2_checkpoint_ascii.txt
    fi

    return $EOK
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
     echo "    Usage: $0 <language> <test list file (one per line)> <list (one per line) of directories to check>"
     echo "  Example: $0 ES         tests/tests.in                p2-81.in"
     echo "  Example: $0 EN         tests/tests.in                p2-88.in"
     echo ""
     exit
fi


# Setup workspace...
GR_LANG=$(echo $1 | tr a-z A-Z)
FNAME_I=$2
LIST_I=$(cat $2)
TEST_DIR=$(dirname $2)

LIST_A=$(cat $3)
BASE_DIR=$(echo $3 | sed 's/\.in//g')

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
    E2_CHECKPOINT_NAME=e2_checkpoint.txt
    if [ "$GR_LANG" == "EN" ]; then
         REPORT=report.pdf
         AUTHORS=authors.txt
    fi
    if [ "$GR_LANG" == "ES" ]; then
         REPORT=report.pdf
         AUTHORS=authors.txt
    fi

    U=""

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

    # remove base microcode...
    mv  $REPORT_DIR/$A/e1_mc_ascii.txt $REPORT_DIR/$A/e1_mc_ascii_step1_submitted.txt
    sed -e 's/rdcycle /tmp_rdcycle /g' \
        -e 's/in /tmp_in /g' \
        -e 's/out /tmp_out /g' \
        -e 's/bck2ftch/bck2ftchX/g' \
        $REPORT_DIR/$A/e1_mc_ascii_step1_submitted.txt > $REPORT_DIR/$A/e1_mc_ascii_step2_clean.txt
     cp $REPORT_DIR/$A/e1_mc_ascii_step2_clean.txt       $REPORT_DIR/$A/e1_mc_ascii.txt

    echo  " ........... EJ-1: "
    ## ej1

       # build test-mC-e1
       cat $TEST_DIR/check-mc-part1         > $REPORT_DIR/$A/test-mc-e1.txt
       cat $REPORT_DIR/$A/e1_mc_ascii.txt  >> $REPORT_DIR/$A/test-mc-e1.txt
      #if ! grep -q "registers" $REPORT_DIR/$A/e1_mc_ascii.txt; then
      #    cat $TEST_DIR/check-mc-part2    >> $REPORT_DIR/$A/test-mc-e1.txt
      #fi
        cat $TEST_DIR/check-mc-part2       >> $REPORT_DIR/$A/test-mc-e1.txt

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




    echo  " ........... EJ-2: "

    # Building $TEST_DIR/check-checkpoint-riscv.txt

    ## ej2
        ## Common to ej2 test

           # make e2-mc1
           cat $TEST_DIR/check-mc-part1  $TEST_DIR/check-mc  $TEST_DIR/check-mc-part2  > $REPORT_DIR/$A/test-mc-e2.txt
           ./wepsim.sh -a show-microcode -c  $REPORT_DIR/$A/e2_checkpoint_ascii.txt > $REPORT_DIR/$A/e2_microcode.txt

           # make e2-mp1
           ./wepsim.sh -a show-assembly  -c  $REPORT_DIR/$A/e2_checkpoint_ascii.txt > $REPORT_DIR/$A/e2_assembly.txt

           # make microcode fields list...
           ./wepsim.sh -a show-microcode-fields --checkpoint $TEST_DIR/check-checkpoint-riscv.txt   > $REPORT_DIR/$A/test-mc-fields.txt
           awk '/^call: \[/,/\]/' $REPORT_DIR/$A/test-mc-fields.txt > /tmp/kk.txt
           mv /tmp/kk.txt $REPORT_DIR/$A/test-mc-fields.txt

           ./wepsim.sh -a show-microcode-fields --checkpoint $REPORT_DIR/$A/e2_checkpoint_ascii.txt > $REPORT_DIR/$A/e2-mc-fields.txt
           awk '/^call: \[/,/\]/' $REPORT_DIR/$A/e2-mc-fields.txt > /tmp/kk.txt
           mv /tmp/kk.txt $REPORT_DIR/$A/e2-mc-fields.txt

           diff $REPORT_DIR/$A/test-mc-fields.txt $REPORT_DIR/$A/e2-mc-fields.txt | grep "imm"      > $REPORT_DIR/$A/e2-mc-fields-imm.txt

           # OK field
           FIELD_SCORE=1
           ##if grep -q "imm" $REPORT_DIR/$A/e2-mc-fields-imm.txt
           ##then
           ##   FIELD_SCORE=0
           ##fi

           # run e2-mc1 e2-mp1
           echo "Original microcode:"                                                                                                    > $REPORT_DIR/$A/output/out-e2-t1.txt
                    ./wepsim.sh --maxc 2000 --maxi 10000 -a run -m ep -f $REPORT_DIR/$A/test-mc-e2.txt -s $REPORT_DIR/$A/e2_assembly.txt >> $REPORT_DIR/$A/output/out-e2-t1.txt
           echo "   ./wepsim.sh --maxc 2000 --maxi 10000 -a run -m ep -f $REPORT_DIR/$A/test-mc-e2.txt -s $REPORT_DIR/$A/e2_assembly.txt >> $REPORT_DIR/$A/output/out-e2-t1.txt"

           # score
           SCORE=1
           if grep -q "ERROR" $REPORT_DIR/$A/output/out-e2-t1.txt
           then
              SCORE=0
           fi

           # report
           IT=$REPORT_DIR/$A/output/out-e2-t1.txt
           OT=$REPORT_DIR/$A/output/out-e2-t1.html
           html_print_pre $IT $OT

           U+="<td align=center><a href=$REPORT_DIR/$A/output/out-e2-t1.html>$SCORE</a></td>\n"

    ## /ej2

    ## Individual Group Report:
    #
    # SI hay que cambiar algo para que les funcione la pr'actica:
    #  * mkdir -p p2-yy/<xxxxx_yyyyy>/ORIGINAL
    #  * cp    -a p2-yy/<xxxxx_yyyyy>/*   p2-yy/<xxxxx_yyyyy>/ORIGINAL
    #
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
  # O+=$(diff $BASE_DIR/$A/e1_checkpoint.txt $BASE_DIR/$A/ORIGINAL/e1_checkpoint.txt)
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

    ## general report
    O=""
    AA=$(echo $A | sed 's/_/ /g')
    for AAI in $AA; do
        O+="<tr>\n"
        O+="<td align=center> <a href=$REPORT_DIR/$A/$A.html>$AAI</a>, <a href=$REPORT_DIR/$A/e1_mc_ascii.txt>mcode</a>, <a href=$REPORT_DIR/$A/e2_assembly.txt>asm</a> </td>\n"
        O+="<td align=center>$A</td>\n"
        O+="<td align=center>$AAI</td>\n"
        O+="<td align=center><a href=$BASE_DIR/$A/>$EOK</a></td>\n"
        O+="<td align=center><a href=$REPORT_DIR/$A/e2-mc-fields-imm.txt>$FIELD_SCORE</a></td>\n"
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

