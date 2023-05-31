
lx-symbols
set pagination off
set logging overwrite on 
set logging file /usr/local/google/home/fuersta/test-vm/exp_scripts/test2_gdb/IO_INSTRUCTION.log
set logging on
set logging redirect on

set width 0
set height 0
set verbose off

break *0xffffffff816dcd33
break *0xffffffff816dcd65
break *0xffffffff815bd498
break *0xffffffff815bd862
break *0xffffffff815bdfd9
break *0xffffffff815bdebf

commands 1-6
where
continue
end

target remote :1234
continue