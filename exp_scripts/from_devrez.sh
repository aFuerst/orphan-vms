#!/bin/sh

user="root"
host="oqv205"
home="/root"

scp -r $user@$host:$home/devrez-results/* ../devrez-results
