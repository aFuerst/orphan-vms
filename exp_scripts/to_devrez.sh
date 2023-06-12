#!/bin/sh

user="root"
host="ikbe1"
home="/root"

scp *.sh $user@$host:$home
