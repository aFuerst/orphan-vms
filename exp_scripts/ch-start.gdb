lx-symbols
set pagination off
set logging overwrite on 
set logging file ./gdb.log
set logging on
set logging redirect on

target remote /tmp/ch-gdb.sock
# continue