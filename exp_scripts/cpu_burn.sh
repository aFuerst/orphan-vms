#!/bin/bash
set -em 

CORE=24
while [[ $# -gt 0 ]]; do
  case $1 in
  	--core)
		CORE="$2"
		shift
		shift
	  ;;
    *)
        echo "Unknown argument $1"
        exit 1
      ;;
  esac
done

taskset -cp $CORE $$
yes > /dev/null