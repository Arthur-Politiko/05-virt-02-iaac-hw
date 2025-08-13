#! /bin/bash
#echo "*** Привет IaaC! ***"

CMDRESULT="0"
SUBNETID="0"
SUBNETNAME=""
NETID="0"
ROUTETABLE=""
ZONENAME=""
TAIL=""
#yc vpc subnet list | mapfile -s 2 -n 1 CMDRESULT 
#read -r yc vpc subnet list |sed -n '4{s/|/\n/g ; s/ //g ; p}'
read -r SUBNETID SUBNETNAME NETID ROUTETABLE ZONENAME TAIL <<<$( yc vpc subnet list |sed -n '4{s/ //g ; s/||/ 0 /g ; s/|/ /g ; p}' )

#echo "$SUBNETID \n $SUBNETNAME \n $NETID \n $ROUTETABLE \n $ZONENAME"
#exit 0

export YC_FOLDER_ID=$(yc config get folder-id)
export YC_ZONE=$ZONENAME
export YC_SUBNET_ID=$SUBNETID
export YC_TOKEN=$(yc iam create-token)

if [ $# -eq 0 ]; then
  echo "Недостаточно аргументов"
fi

case "$1" in
	validate)
		packer validate "$2"
	  	exit 0
		;;
	build)
		packer build "$2"
		exit 0 
		;;
	*)
		echo "Неизвестная команда $1"
		;;
esac

#packer validate $1

