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


mkdir -p  /work/tester
cp -a /work/tests           /work/tester/tests
cp -a /work/scripts/*       /work/tester/
cp -a /work/submissions/*   /work/tester/
cp -a /opt/wepsim           /work/tester/wepsim

ln -s                 /work/tester/wepsim/wepsim.sh /work/tester/wepsim.sh
chown -R $(id -un):$(id -gn) /work/tester

/work/tester/help.sh

