#!/bin/bash

#Name: Simple backup script
#Author: Snake
#version: 04012013

#Format with week number
DEST_DIR=`date +%G-%V`
homedir="/home/snake"
etcdir="/etc"
dstdir="/storage/st02/config"
docdir="$homedir/Documents"
workdir="$homedir/workspace"
hostname=`cat /etc/hostname`
#pidgindir="/home/snake/.purple"
#pidginarc=`date +%F-%s`.tgz
rsync="/usr/bin/rsync -aHz --delete --delete-excluded=.hg"
archive="/bin/tar -zc --listed-incremental="$dropbox/$DEST_DIR"/backup.snar \
--exclude-caches --no-check-device --exclude-vcs --preserve-permissions --totals \
--exclude-tag-under=IGNORE.TAG -f"
#homedir="/home/snake"
homearc=`date +%F-%s`.tgz
excmd="--exclude-from=$workdir/rsync-excludes"
incmd="--"
echo "Sync $etcdir files on $hostname to $dstdir/$hostname"
$rsync $etcdir "$dstdir/$hostname"
#echo "Clean old backup files"
cd $dstdir/$hostname
/usr/bin/hg add
/usr/bin/hg commit -m `date +%F-%s` -u Snake