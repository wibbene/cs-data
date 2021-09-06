#!/bin/bash

#Error Checking

set -e

trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT


#get current directory and set it as a variable
DIR=$( cd "$( dirname "$0" )" && pwd )
#Set CSDATA as CS-Data so we don't have to muck around with quotes in directory names
CSDATA='CS-Data'

echo "Welcome to the CS-Data Installation script for debian based systems"

echo "What is your username in CS-Data?"

read USERNAME

echo "Hello $USERNAME"

echo "What is your password to CS-Data?"

read PASSWORD

echo "I am not showing your password for security reasons."

echo "Checking to see if CS-Data is reachable"

if ping -c 1 10.92.21.12 &> /dev/null
then
	echo "CS-Data is reachable"
else
	echo "CS-Data is not reachable. Please check to make sure that the server is up and your network settings are configured properly"
	exit 404
fi

echo "Checking to see if we have the directories we need and if not, creating them"

#Check for credentials

make_cred() {
	echo "username=$USERNAME" >> $DIR/$CSDATA/.smbcred
        echo "password=$PASSWORD" >> $DIR/$CSDATA/.smbcred
        echo "domain=domain1" >> $DIR/$CSDATA/.smbcred

}




#Check if CS-Data Directory exists
if [ ! -d $DIR/$CSDATA ]; then
	mkdir $DIR/$CSDATA
	echo "Didn't find the CS-Data directory, Creating it now"
	make_cred
	
fi
#Tell user we found directory
if [ -d $DIR/$CSDATA ]; then
	echo 'Found CS-Data'
	if [ ! -f $DIR/$CSDATA/.smbcred ]; then
		make_cred
	fi
fi

#Check if Courses does not exist. If it doesn't create it
if [ ! -d $DIR/$CSDATA/Courses ]; then
	mkdir $DIR/$CSDATA/Courses
	echo "Didn't find Courses Directory. Created it"
fi

#Tell user we found directory
if [ -d $DIR/$CSDATA/Courses ]; then
	echo "Found Courses"
fi

if [ ! -d $DIR/$CSDATA/Etc ]; then
	mkdir $DIR/$CSDATA/Etc
	echo "Didn't find Etc Directory. Created it"
fi

if [ -d $DIR/$CSDATA/Etc ]; then
	echo 'Found Etc'
fi

if [ ! -d $DIR/$CSDATA/Students ]; then
	mkdir $DIR/$CSDATA/Students
	echo "Didn't find the Students Directory. Created it."
fi 

if [ -d $DIR/$CSDATA/Students ]; then
	echo 'Found Students Directory'
fi

if [ ! -d $DIR/$CSDATA/Students/${USERNAME} ]; then
	mkdir $DIR/$CSDATA/Students/$USERNAME
	echo "Didn't find the $USERNAME directory. Created it."
fi

if [ -d $DIR/$CSDATA/Students/${USERNAME} ]; then
	echo "Found the $USERNAME Directory"
fi

### Check for cifs-utils ###

CIFS='cifs-utils'


echo 'Checking if cifs-utils is installed'
INSTALLED=$(dpkg-query -W --showformat='${Status}\n' $CIFS|grep "install ok installed")

if [ $(dpkg-query -W -f='${Status}' cifs-utils 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  sudo apt install cifs-utils;
fi



### Mounting ###

echo 'Mounting CS-Data'

sudo mount -t cifs //10.92.21.12/Courses $DIR/$CSDATA/Courses -o credentials=$DIR/$CSDATA/.smbcred,iocharset=utf8,sec=ntlmssp,vers=2.0

echo "Mounting $USERNAME Folder"

#This mount makes sure that the appropriate folder is owned by the user, not Root. This allows for uploads
sudo mount -t cifs //10.92.21.12/Students/$USERNAME $DIR/$CSDATA/Students/$USERNAME -o credentials=$DIR/$CSDATA/.smbcred,iocharset=utf8,sec=ntlmssp,vers=2.0,uid=$(id -u),gid=$(id -g)

echo "Mounting Etc Folder"

sudo mount -t cifs //10.92.21.12/Etc $DIR/$CSDATA/Etc -o credentials=$DIR/$CSDATA/.smbcred,iocharset=utf8,sec=ntlmssp,vers=2.0

echo "Mounting is complete. Please remember to use the disconnect script when you are finished access CS-Data"

exit 0
