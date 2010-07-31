#!/bin/bash

#~ set -x

PREVIEWDIR="/home/dmaphy/webroot/websites/plugins.geany.org/"
STABLEDIR="/home/dmaphy/plugins.geany.org/"
BACKUPDIR="/home/dmaphy/plugins.geany.org.backup/"
EXCLUDE=".svn gencontent.sh push2stable.sh rst2html_template.txt templates tidy.conf rst2html_config.conf"

if [ ! -d $PREVIEWDIR ]; then
	echo "Could not find $PREVIEWDIR. Exiting..";
	exit 127;
fi

if [ ! -d $STABLEDIR ]; then
	echo "Could not find $STABLEDIR. Trying to create...";
	mkdir -p $STABLEDIR;
fi

if [ ! -d $BACKUPDIR ]; then
	echo "Could not find $BACKUPDIR. Trying to create...";
	mkdir -p $BACKUPDIR;
fi

EXARG=""
for i in $EXCLUDE;
do
	EXARG="$EXARG --exclude $i"
done


# check if $STABLEDIR is empty and backup if it is not
ls $STABLEDIR/* > /dev/null 2>&1;
if [ $? -eq 0  ]; then
	rsync -avC $EXARG --delete $STABLEDIR $BACKUPDIR
fi

rsync -avC $EXARG --delete $PREVIEWDIR $STABLEDIR
