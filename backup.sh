#!/bin/bash

#Name: Simple backup script
#Author: Snake
#version: 17012014

#Format with week number
DEST_DIR=`date +%G-%V`
docdir="/home/snake/Documents"
workdir="/home/snake/workspace"
yadisk="/storage/st02/cloud/Yandex.Disk/"
pidgindir="/home/snake/.purple"
pidginarc=`date +%F-%s`.tgz
dropbox="/storage/st02/current/thinkpad"
rsync="/usr/bin/rsync -aHz --delete"
archdir="/storage/st02/archive/thinkpad/"
archive="/bin/tar -zc --listed-incremental="$dropbox/$DEST_DIR"/backup.snar \
--exclude-caches --no-check-device --exclude-vcs --preserve-permissions --totals \
--exclude-tag-under=IGNORE.TAG -f"
homedir="/home/snake"
homearc=`date +%F-%s`.tgz
#archive="/bin/tar -zcf"
#Daily home backup
mkdir -p $dropbox/$DEST_DIR;
cd $homedir && $archive $dropbox/$DEST_DIR/$homearc .
#Clean old archives older than 10 days
echo "Clean old backup files"
cd $dropbox
for i in 201*
do
    echo $i
    if [ -d "$i" ]; 
    then
	if [ $DEST_DIR != "$i" ];
	then
	    mv $i $archdir
	fi
    fi
done
#Daily Docs and workspace sync for cloud
#echo "Sync Docs and scripts"
#$rsync $docdir $dropbox
#$rsync $workdir $dropbox
#$rsync $dropbox/ $yadisk
