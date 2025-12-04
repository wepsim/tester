#!/bin/bash
#set -x

#
#  Copyright 2019-2026 Saul Alonso Monsalve, Felix Garcia Carballeira, Jose Rivadeneira Lopez-Bravo, Alejandro Calderon Mateos,
#
#  This file is part of WepSIM proyect.
#
#  WepSIM is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  WepSIM is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with WepSIM.  If not, see <http://www.gnu.org/licenses/>.
#



#
# Usage
#

if [ $# -eq 0 ]; then
	$0 help
	exit
fi


#
# check docker
#

WSSH_VER="v1.0"
DOCKER_PREFIX_NAME=docker

docker -v >& /dev/null
status=$?
if [ $status -ne 0 ]; then
     echo ""
     echo "  WepSIM Tester on Docker ($WSSH_VER) "
     echo " --------------------------------"
     echo ""
     echo ": ERROR: docker is not found in this computer."
     echo ":"
     echo ": Just in case, please check:"
     echo ":  * Did you install docker?"
     echo ":    Please visit https://docs.docker.com/get-docker/"
     echo ":"
     echo ":  * Are you running 'Docker Desktop', 'docker daemon' or similar solution?"
     echo ":    Please visit https://docs.docker.com/"
     echo ""
     exit
fi


#
# for each argument, try to execute it
#

while (( "$#" ))
do
	arg_i=$1
	case $arg_i in
	     start)
		# Check params
		if [ ! -f docker/ws-dockerfile ]; then
		    echo ": The docker/ws-dockerfile file is not found."
		    echo ": * Did you execute git clone https://github.com/acaldero/wepsim_tester.git?."
		    echo ""
		    exit
		fi

		HOST_UID=$(id -u)
		HOST_GID=$(id -g)

		# Build image
		echo "Building image (it may take a while)..."
		cd docker
		docker image build -t ws --build-arg UID=$HOST_UID --build-arg GID=$HOST_GID -f ws-dockerfile .
		cd ..

		# Build tester (just in case)
		mkdir -p results
		chown -R $HOST_UID:$HOST_GID results

		# Start container cluster (single node)
		echo "Building container..."
		HOST_UID=$HOST_UID HOST_GID=$HOST_GID docker compose -f docker/ws-dockercompose.yml up -d --scale node=1
		if [ $? -gt 0 ]; then
		    echo ": The docker compose command failed to spin up containers."
		    echo ": * Did you execute git clone https://github.com/acaldero/wepsim_tester.git?."
		    echo ""
		    exit
		fi

		# Check params
                CO_ID=1
		CO_NC=$(docker ps -f name=$DOCKER_PREFIX_NAME -q | wc -l)
                if [ $CO_ID -gt $CO_NC ]; then
			echo "ERROR: Container ID $CO_ID out of range (1...$CO_NC)"
                	shift
                        continue
                fi

		# Bash on container...
		echo "Executing /bin/bash on container $CO_ID..."
		CO_NAME=$(docker ps -f name=$DOCKER_PREFIX_NAME -q | head -$CO_ID | tail -1)
		docker exec -it $CO_NAME /bin/bash
	     ;;

	     stop)
		# Stopping containers
		echo "Stopping containers..."
		HOST_UID=$HOST_UID HOST_GID=$HOST_GID docker compose -f docker/ws-dockercompose.yml down
		if [ $? -gt 0 ]; then
		    echo ": The docker compose command failed to stop containers."
		    echo ": * Did you execute git clone https://github.com/acaldero/wepsim_tester.git?."
		    echo ""
		    exit
		fi

		# Remove container cluster (single node) files...
		# rm -fr machines
	     ;;

	     status)
		echo "Show status of current containers..."
		docker ps
	     ;;

	     cleanup)
		# Removing everything (warning) 
		echo "Removing containers and images..."
                docker rm      -f $(docker ps     -a -q)
                docker rmi     -f $(docker images -a -q)
                docker volume rm  $(docker volume ls -q)
                docker network rm $(docker network ls|tail -n+2|awk '{if($2 !~ /bridge|none|host/){ print $1 }}')
	     ;;

	     help)
		echo ""
		echo "  WepSIM Tester on Docker ($WSSH_VER) "
		echo " --------------------------------"
		echo ""
		echo "  Usage: $0 <action> [<options>]"
		echo ""
		echo "    1) First action is start:"
		echo "        $0 start"
		echo ""
		echo "    2) Then you can perform different tasks, please execute help.sh for more info:"
		echo "        ./help.sh"
		echo ""
		echo "    3) The last action is stop:"
		echo "        $0 stop"
		echo ""
	     ;;

	     *)
		echo ""
		echo "Unknow command: $1"
                $0 help
	     ;;
	esac

	shift
done

