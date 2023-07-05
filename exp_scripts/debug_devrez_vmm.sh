#!/bin/bash
# Run with sudo

GDB_FILE="$(pwd)/ch-start.log"
while [[ $# -gt 0 ]]; do
  case $1 in
    --cmds)
      GDB_FILE=true
      shift
      shift
      ;;
    *)
      shift
      ;;
  esac
done

gdb_sock=/tmp/vmm-gdb.sock
if [[ -e "$gdb_sock" ]]; then
	rm -f $gdb_sock
fi

# forward local sock to devrez gdbserver
ssh -L $gdb_sock:localhost:2345 root@oqv142 "sleep 10h" < /dev/null > /dev/null 2> /dev/null &
pid=$!
cleanup() {
  kill $pid
  echo "closing ssh"
  exit 0
}
trap cleanup SIGINT

sleep 5
rust-gdb -x vmm-devrez.gdb
# /usr/local/google/home/fuersta/cloud-hypervisor/target/release/cloud-hypervisor
cleanup