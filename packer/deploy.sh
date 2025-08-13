#! /bin/bash
#echo "*** Привет IaaC! ***"

CMD_RESULT="0"
SUBNET_ID="e2luplcfdjidq47o2as9"
SUBNET_NAME=""
NET_ID="0"
ROUTE_TABLE=""
ZONE_NAME="ru-central1-b"
TAIL=""
VM_NAME="pc1"
#SSH_PUB="$( cat ../keys/vm-ubuntu1.pub )"
SSH_PUB="../keys/vm-ubuntu1.pub"

read -r SUBNET_ID SUBNET_NAME NET_ID ROUTE_TABLE ZONE_NAME TAIL <<<$( yc vpc subnet list |sed -n '4{s/ //g ; s/||/ 0 /g ; s/|/ /g ; p}' )

#echo "$SUBNETID \n $SUBNETNAME \n $NETID \n $ROUTETABLE \n $ZONENAME"
#exit 0

export YC_FOLDER_ID=$(yc config get folder-id)
export YC_ZONE=$ZONE_NAME
export YC_SUBNET_ID=$SUBNET_ID
#export YC_TOKEN=$(yc iam create-token)
export YC_IMAGE_ID="fd8kmj2v76ipf6cl89is"

#echo "========== список доступных образов =========="
#yc compute image list
#

#if [ $# -eq 0 ]; then
#  echo "Недостаточно аргументов"
#fi


case "$1" in
	spawn)
		CMD_RESULT=$( yc compute instance create --name "ubuntupc1" --hostname "ubuntupc1" --zone=$ZONE_NAME --create-boot-disk size=20GB,image-id=$YC_IMAGE_ID --cores=2 --memory=2G --core-fraction=20 --network-interface subnet-id=$SUBNET_ID,ipv4-address=auto,nat-ip-version=ipv4 --ssh-key $SSH_PUB )
	  	exit 0
		;;
	*)
		echo "Неизвестная команда $1"
		;;
esac

