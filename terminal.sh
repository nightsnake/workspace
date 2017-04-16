#!/bin/bash
rdesktop -f -u $1 -p $2 -N -5 -z -g 1280x1024 -r disk:home=/home/snake $3
