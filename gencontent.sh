#!/bin/bash

# debug mode
#~ set -x

# gencontent.sh
# Generates the *.html files in the content/ directory on the
# plugins.geany.org website
#
# (C) Copyright 2010 by Dominic Hopf <dmaphy@googlemail.com>
# Version: 1.2.0
# Last Change: 2013-04-15

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
# 2013-04-15  Volodymyr Kononenko  <vm@kononenko.ws>
# * the plugin listing (left side navigation bar) is now being generated
#   from all plugins, available in master branch
# * if the plugin had different page in previous Geany versions, these
#   pages are also being generated. Links to them are included in the
#   bottom of plugin page
# * fixed checking exceptions in EXCLUDE_PLUGINS
#
# 2011-12-17 Dominic Hopf <dmaphy@googlemail.com>
# * generate .html files from READMEs for the latest Geany-Plugins version
#   instead of git master
#
# 2011-12-11 Dominic Hopf <dmaphy@googlemail.com>
# * use the new Git repository
#
# 2010-01-21 Dominic Hopf <dmaphy@googlemail.com>
# * remove unneccessary code which is trying to patch files but not working
#   correctly
#
# 2010-01-21 Dominic Hopf <dmaphy@googlemail.com>
# * add a sanity check, if the README file for a plugin exists
#
# 2010-01-09  Dominic Hopf  <dmaphy@googlemail.com>
# * write first version of this file with basic functionality

# ATTENTION: If you change any path below, don't forget the trailing slashes,
# they are very important and the script will not work correctly if they are
# missing!

# SOURCESDIR is the directory, where the README files will be found
SOURCESDIR=${HOME}"/.tmp/geany-plugins/"

WORKDIR=$(pwd)"/"

# CONTENTDIR is the directory, where the generated HTML files will be put
CONTENTDIR=${WORKDIR}"content/"

# LOGDIR is the directory where to put any logfiles and information about the
# generation of the content files
LOGDIR=${WORKDIR}"gencontent_logs/"

# plugins to exclude from the nightly re-generation via rst2html because they
# have a separate HTML page not generated from the README file
declare -a EXCLUDE_PLUGINS=( geanylatex geanylua jsonprettifier quick_open_file sendmail )

RST2HTML=$(which rst2html)
TIDY=$(which tidy)

# List of plugins, available in the letest release
declare -a RELEASE_PLUGIN_LIST

# List of plugins, available in the letest release
declare -a MASTER_PLUGIN_LIST


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


in_array()
{
    declare -a arr=("${!2}")
    found=0

    for i in "${arr[@]}"
    do
        if [ "${i}" == "$1" ]; then
            found=1
        fi
    done

    return ${found}
}


function prepare_source_dir()
{
    if [ ! -d "${SOURCESDIR}" ]; then
        echo -e "Directory containing sources $SOURCESDIR could not be found.\nTrying to clone from git...\n"
        git clone git://github.com/geany/geany-plugins.git ${SOURCESDIR}
    fi

    if [ $? -ne 0 ]; then
        echo "git clone failed. Exiting..."
        exit 1
    fi
}


function prepare_content_dir()
{
    if [ ! -d "${CONTENTDIR}" ]; then
        echo -e "Directory containing contents $CONTENTDIR could not be found!\n"
        exit 1
    fi
}


function prepare_log_dir()
{
    mkdir -p ${LOGDIR}
}


function add_to_navigation()
{
    dir=$1
    title=$(echo ${dir} | sed 's/\([a-z]\)\([a-zA-Z0-9]*\)/\u\1\2/g')
    echo "<li><a href=\"${dir}.html\">${title}</a></li>" >> "${CONTENTDIR}geany-plugins-listing.html"
}


function is_plugin()
{
    f=$1
    cd ${SOURCESDIR}
    if [ -d "${f}" ] && [ "${f}x" != "buildx" ] && [ "${f}x" != "pox" ]; then
        return 1
    else
        return 0
    fi
}


# Generates geany-plugins-listing.html - the file which is included as navigation
function gen_plugins_listing_html()
{
    cd ${SOURCESDIR}

    echo "Checking out master branch..."
    git checkout master
    echo "Updating master branch..."
    git pull

    cd ${WORKDIR}

    # reset old geany-plugins-listing.html
    rm -f ${CONTENTDIR}"geany-plugins-listing.html"

    for dir in $(ls ${SOURCESDIR})
    do
        is_plugin ${dir}
        if [ $? -eq 1 ]; then
            add_to_navigation ${dir}
            MASTER_PLUGIN_LIST+=("${dir}")
        fi
    done
}


function gen_html_from_readme()
{
    plugin="$1"
    dir="$2"
    LOGFILE="${LOGDIR}${plugin}_log_"$(date "+%Y-%m-%d")

    cd ${CONTENTDIR}
    # TODO: newer versions of rst2html may face problems with the configuration files encoding
    $RST2HTML -s --config=${CONTENTDIR}"rst2html_config.conf" ${SOURCESDIR}${plugin}/README ${SOURCESDIR}.README.html 2> $LOGFILE
    cd - > /dev/null

    retcode=$?
    if [ ${retcode} -ne 0 ]; then
        echo -e "$RST2HTML exited with ${retcode}.\n\n"
    fi

    $TIDY -config ${WORKDIR}tidy.conf .README.html >> $LOGFILE 2>&1
    case "$?" in
        1)
            echo -e "$TIDY exited with 1. There were warnings."
            ;;
        2)
            echo "$TIDY exited with 2. There were errors.\n\n"
            ;;
        *)
            echo -e "$TIDY exited with $?. Everything should be fine.\n"
            ;;
    esac
    echo -e "Result:\t${dir}${plugin}.html\nLog:\t${LOGFILE}\n"
    echo -e "\n\n" >> $LOGFILE

    # since tidy just outputs spaces, not tabs, we'll replace those spaces
    # with tabs again ourself
    sed -i "s/  /\t/g" .README.html
    # remove hard-coded references to http://plugins.geany.org and make the links
    # protocol-relative to not break SSL
    sed -i "s,http://plugins.geany.org/,//plugins.geany.org/,g" .README.html
    cp .README.html ${dir}${plugin}.html
    echo -e "\n\n" >> ${LOGFILE}
}


function gen_plugin_pages()
{
    cd $SOURCESDIR
    for fname in $(ls ${SOURCESDIR})
    do
        is_plugin ${fname}
        if [ $? -ne 1 ]; then
            continue
        fi

        RELEASE_PLUGIN_LIST+=(${fname})

        in_array ${fname} EXCLUDE_PLUGINS[@]
        if [ $? -eq 1 ]; then
            continue
        fi

        prevtag=""
        for tag in $(git tag | tac)
        do
            git checkout -q ${tag}
            if [ ${tag} == $(git tag | tail -n 1) ]; then
                if [ -s ${SOURCESDIR}${fname}/README  ]; then
                    gen_html_from_readme ${fname} ${CONTENTDIR}
                else
                    echo -e "File ${SOURCESDIR}${fname}/README not found.\nYou might want to have a look whats up there.\nCopying no-readme-template instead."
                    cp ${WORKDIR}/templates/no-readme-template.html ${CONTENTDIR}${fname}.html
                    sed -i "s/{plugin_name}/${fname}/g" ${CONTENTDIR}${fname}.html
                    prevtag=${tag}
                    continue
                fi
            else
                diff=$(git diff ${prevtag} -- ${fname}/README)
                if [ -n "${diff}" ]; then
                    # diff output is not empty
                    mkdir -p ${CONTENTDIR}${tag}
                    gen_html_from_readme ${fname} ${CONTENTDIR}${tag}"/"
                fi
            fi
            prevtag=${tag}
        done

        git checkout -q $(git tag | tail -n 1)
    done
}


# The function generates pages for plugins, which are missing in release
# but are present in master branch
function gen_new_plugins_pages()
{
    git checkout master
    for plugin in ${MASTER_PLUGIN_LIST[@]}
    do
        in_array ${plugin} RELEASE_PLUGIN_LIST[@]
        if [ $? -eq 0 ]; then
            gen_html_from_readme ${plugin} ${CONTENTDIR}
        fi
    done
}


function add_links_to_old_pages()
{
    declare -A header_added
    for plugin in ${RELEASE_PLUGIN_LIST[@]}
    do
        header_added["${plugin}"]=0
    done

    for tag in $(ls ${CONTENTDIR})
    do
        if [ ! -d ${CONTENTDIR}${tag} ]; then
            # this is not dir with old pages. Skip it
            continue
        fi
        for plugin in $(ls ${CONTENTDIR}${tag} | awk -F'.' '{print $1}')
        do
            if [ ${header_added[${plugin}]} -eq 0 ]; then
                # Adding header
                echo -e "<div class=\"section\" id=\"docs-for-previous-versions\">\n<h3>\nDocs for previous versions\n</h3>\n<p>\n<ul>\n" >> ${CONTENTDIR}${plugin}.html
                header_added["${plugin}"]=1
            fi
            echo -e "<li><a href=\"index.php?site=${tag}/${plugin}\">${tag}</a></li>\n" >> ${CONTENTDIR}${plugin}.html
        done
    done

    # closing opened tags
    for plugin in "${!header_added[@]}"
    do
        if [ ${header_added[${plugin}]} -eq 1 ]; then
            echo -e "</ul>\n</p>\n</div>" >> ${CONTENTDIR}${plugin}.html
            $TIDY -config ${WORKDIR}tidy.conf ${CONTENTDIR}${plugin}.html > /dev/null 2>&1
        fi
    done
}


# clean up any unneccessary files
function clean_up()
{
    # delete logfiles older than 7 days
    find $LOGDIR -mtime +7 -delete
}


function main()
{
    prepare_source_dir
    prepare_content_dir
    prepare_log_dir
    gen_plugins_listing_html
    gen_plugin_pages
    gen_new_plugins_pages
    add_links_to_old_pages
    clean_up
}

main
