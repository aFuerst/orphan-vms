#!/bin/sh

user="root"
host="ikbe1"
home="/root"

scp -r $user@$host:$home/devrez-results/* ../devrez-results
