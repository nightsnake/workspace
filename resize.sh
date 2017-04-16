#!/bin/bash

FONT="Ubuntu-Regular"
LOGO="stamp.png"
FILE=$1
GRAVITY="southeast"
PREFIX="_"
TEXT="Alexey Uchakin | http://night-snake.net"
POINTSIZE=18
SIZE="1200x1200"
PATH=`pwd`

#Create the logo file with copyright information
if [ ! -e $LOGO ]
then
 /usr/bin/convert -size 320x28 canvas:none -font $FONT -pointsize $POINTSIZE -gravity center -draw "fill '#fff3' rectangle 0,0 320,28" -draw "fill black  text 0,0 '$TEXT'" -rotate -90 $LOGO
fi

#Create the output file
if [ $FILE ] 
then
 echo "Resize $FILE to $SIZE"
 /usr/bin/convert -resize $SIZE $PATH/$FILE $PATH/$PREFIX$FILE
 /usr/bin/composite -gravity $GRAVITY -geometry +0+0 $LOGO $PATH/$PREFIX$FILE $PATH/$PREFIX$FILE
else
 echo "Please, set the input file!"
fi
