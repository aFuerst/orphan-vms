#!/bin/bash
# Run with sudo

GDB_FILE="$(pwd)/ch-start.gdb"
while [[ $# -gt 0 ]]; do
  case $1 in
    --cmds)
      shift
      GDB_FILE=$1
      shift
      ;;
    *)
      shift
      ;;
  esac
done

gdb_sock=/tmp/ch-gdb.sock
if [[ -e "$gdb_sock" ]]; then
	rm -f $gdb_sock
fi

# forward local sock to devrez
ssh -L $gdb_sock:$gdb_sock root@oqv205 "sleep 24h" < /dev/null > /dev/null 2> /dev/null &
pid=$!
cleanup() {
  kill $pid
  echo "closing ssh"
  popd > /dev/null
  exit 0
}
trap cleanup SIGINT
sleep 5

linux_dir="/usr/local/google/home/fuersta/linux"
pushd $linux_dir > /dev/null
gdb vmlinux -x $GDB_FILE
cleanup
