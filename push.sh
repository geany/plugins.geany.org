#!/bin/bash

#~ set -x

SOURCEDIR="/home/dmaphy/webroot/websites/plugins.geany.org/"
PREVIEWDIR="/home/dmaphy/plugins.geany.org_preview/"
STABLEDIR="/home/dmaphy/plugins.geany.org_stable/"
BACKUPDIR="/home/dmaphy/plugins.geany.org.backup/"
EXCLUDE=".svn gencontent.sh push2stable.sh rst2html_template.txt templates tidy.conf rst2html_config.conf"


if [ ! -d $SOURCEDIR ]; then
	echo "Could not find $SOURCEDIR. Exiting..";
	exit 127;
fi


catch_error()
{
	RC=$1;
	if [ $RC -eq 0 ]; then
		echo "done."
	else
		echo "failed. Exiting...";
		exit 127;
	fi
}


if [ ! -d $PREVIEWDIR ]; then
	echo "Could not find $PREVIEWDIR. Trying to create...";
	mkdir -p $PREVIEWDIR;
	catch_error $?;
fi


if [ ! -d $STABLEDIR ]; then
	echo "Could not find $STABLEDIR. Trying to create...";
	mkdir -p $STABLEDIR;
	catch_error $?;
fi


if [ ! -d $BACKUPDIR ]; then
	echo "Could not find $BACKUPDIR. Trying to create...";
	mkdir -p $BACKUPDIR;
	catch_error $?;
fi


EXARG=""
for i in $EXCLUDE;
do
	EXARG="$EXARG --exclude $i";
done


if [ -z $1  ]; then
	echo "Usage: $0 [preview|stable]";
else
	case $1 in
		"preview")
			# backup is not necessary, when pushing to preview..
			rsync -avC $EXARG --delete $PREVIEWDIR $STABLEDIR
			;;
		"stable")
			# check if $STABLEDIR is empty and backup if it is not
			ls $STABLEDIR/* > /dev/null 2>&1;
			if [ $? -eq 0  ]; then
				rsync -avC $EXARG --delete $STABLEDIR $BACKUPDIR
			fi

			rsync -avC $EXARG --delete $PREVIEWDIR $STABLEDIR
			;;
		*)
			echo "Usage: $0 [preview|stable]";
			;;
	esac

fi
