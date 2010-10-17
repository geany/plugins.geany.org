#!/bin/bash

# debug mode
#~ set -x

# gencontent.sh
# Generates the *.html files in the content/ directory on the
# plugins.geany.org website
#
# (C) Copyright 2010 by Dominic Hopf <dh@dmaphy.de>
# Version: 1.0.0
# Last Change: 2010-07-17

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# ChangeLog:
# 2010-01-21 Dominic Hopf <dh@dmaphy>
# * remove unneccessary code which is trying to patch files but not working
#   correctly
#
# 2010-01-21 Dominic Hopf <dh@dmaphy>
# * add a sanity check, if the README file for a plugin exists
#
# 2010-01-09  Dominic Hopf  <dh@dmaphy.de>
# * write first version of this file with basic functionality

# ATTENTION: If you change any path below, don't forget the trailing slashes,
# they are very important and the script will not work correctly if they are
# missing!

# SOURCESDIR is the directory, where the README files will be found
SOURCESDIR=$HOME"/projects/geany-plugins/trunk/geany-plugins/"

# CONTENTDIR is the directory, where the generated HTML files will be pushed
CONTENTDIR="./content/"

# LOGDIR is the directory where to put any logfiles and information about the
# generation of the content files
LOGDIR="./gencontent_logs/"

# plugins to exclude from the nightly re-generation via rst2html because they
# have a separate HTML page not generated from the README file
EXCLUDE_PLUGINS=( geanylatex geanysendmail geanylua )

RST2HTML="/usr/bin/rst2html"
TIDY="/usr/bin/tidy"


if [ ! -x "$RST2HTML" ]
then
	echo "rst2html not found. Exiting."
	exit 127
fi


if [ ! -x "$TIDY" ]
then
	echo "tidy not found. Exiting."
	exit 127
fi


# small function to check an array if an element is included
in_array()
{
	NEEDLE=$1
	shift

	# search for the NEEDLE $1 in the haystack $@
	for j in $@;
	do
		if [ $NEEDLE == $j ]; then
			return 0;
		fi;
	done;

	return 1;
}


if [ ! -d $SOURCESDIR ]; then
	echo -e "Directory containing sources $SOURCESDIR could not be found!\n"
	exit 1
else
	svn update $SOURCESDIR
fi


if [ ! -d $CONTENTDIR ]; then
	echo -e "Directory containing contents $CONTENTDIR could not be found!\n"
	exit 1
fi


mkdir -p $LOGDIR


# reset geany-plugins-listing.html, the file which is included as navigation
rm -f $CONTENTDIR"geany-plugins-listing.html"
touch $CONTENTDIR"geany-plugins-listing.html"

for i in `ls $SOURCESDIR`;
do
	if [ -d $SOURCESDIR$i -a $i"x" != "buildx" -a $i"x" != "pox" ]; then
		# check if the current plugin is included in the exclusion-list...
		in_array $i ${EXCLUDE_PLUGINS[@]}

		if [ $? -eq 0 ]; then # ... if yes, ...
			# ... add it to the navigation ...
			title=`echo ${i} | sed 's/\([a-z]\)\([a-zA-Z0-9]*\)/\u\1\2/g'`
			echo "<li><a href=\"$i.html\">${title}</a></li>" >> $CONTENTDIR"geany-plugins-listing.html"
			continue # ... and jump to the next one
		fi;

		LOGFILE=$LOGDIR$i"_log_"`date "+%Y-%m-%d"`

		echo -e "Generating content file $i.html...\n\n" > $LOGFILE

		if [ -s $SOURCESDIR$i/README  ]; then
			# TODO: there is still output from rst2html to the shell, that ideally should'nt be
			# TODO: newer versions of rst2html may face problems with the configuration files encoding
			$RST2HTML -s --config=$CONTENTDIR"rst2html_config.conf" $SOURCESDIR$i/README | tee .README.html >> $LOGFILE 2>&1
			title=`echo ${i} | sed 's/\([a-z]\)\([a-zA-Z0-9]*\)/\u\1\2/g'`
			echo "<li><a href=\"$i.html\">${title}</a></li>" >> $CONTENTDIR"geany-plugins-listing.html"

			if [ $? -ne 0 ]; then
				echo -e "$RST2HTML exited with $?.\n\n"
				continue
			fi
		else
			echo -e "File $SOURCESDIR$i/README not found.\nYou might want to have a look whats up there.\nCopying no-readme-template instead.."
			cp "./templates/no-readme-template.html" $CONTENTDIR$i.html
			sed -i "s/{plugin_name}/$i/g" $CONTENTDIR$i.html
			continue
		fi
		echo -e "\n\n" >> $LOGFILE


		$TIDY -config $CONTENTDIR"tidy.conf" .README.html >> $LOGFILE 2>&1
		case "$?" in
			1)
				echo -e "$TIDY exited with 1. There were warnings, but this is okay."
				echo -e "You maybe should have another look at $CONTENTDIR$i.html yourself.'\n"
				;;
			2)
				echo "$TIDY exited with 2. There were errors.\n\n"
				continue
				;;
			*)
				echo -e "$TIDY exited with $?. Everything should be fine.\n"
				;;
		esac
		echo -e "\n\n" >> $LOGFILE

		# since tidy just outputs spaces, not tabs, we'll replace those spaces
		# with tabs again ourself
		sed -i "s/  /\t/g" .README.html
		cp .README.html $CONTENTDIR$i.html
		echo -e "\n\n" >> $LOGFILE

	fi # if [ -d $SOURCESDIR$i -a $i"x" != "buildx" -a $i"x" != "pox" ];
done

# clean up any unneccessary files
find $LOGDIR -mtime +7 -delete # delete logfiles older than 7 days
