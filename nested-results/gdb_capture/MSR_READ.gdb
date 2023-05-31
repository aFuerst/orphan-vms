
lx-symbols
set pagination off
set logging overwrite on 
set logging file /usr/local/google/home/fuersta/test-vm/exp_scripts/test2_gdb/MSR_READ.log
set logging on
set logging redirect on

set width 0
set height 0
set verbose off

break *0xffffffff81103321
break *0xffffffff810f5b03
break *0xffffffff81f43be1

commands 1-3
where
continue
end

target remote :1234
continue