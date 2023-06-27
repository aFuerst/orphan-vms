#!/bin/sh

user="root"
host="lpbb9"
home="/root"

scp -r $user@$host:$home/devrez-results/* ../devrez-results
