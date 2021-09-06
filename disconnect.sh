#!/bin/bash

#get current directory and set it as a variable
DIR=$( cd "$( dirname "$0" )" && pwd )
#Set CSDATA as CS-Data so we don't have to muck around with quotes in directory names
CSDATA='CS-Data'



echo "Disconnecting from CS-Data"

if sudo umount -a -t cifs -l ; then
	echo "Succesfully disconneted"
else
	echo "WARNING: Disconnecting has failed. Do not manually delete your students directory or you will lose data"
	exit 1
fi

echo "Cleaning up directories"

rm -rf $DIR/$CSDATA

echo "All done. Have a good day!"
