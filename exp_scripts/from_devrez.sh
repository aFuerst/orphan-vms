#!/bin/sh

user="root"
host="ikbe1"
home="/user/fuersta"

scp -r $user@$host:$home/exp_scripts/devrez-results ../devrez-results
