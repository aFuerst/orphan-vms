
lx-symbols
set pagination off
set logging overwrite on 
set logging file /usr/local/google/home/fuersta/test-vm/nested-results/gdb_capture/EPT_VIOLATION.log
set logging on
set logging redirect on

set width 0
set height 0
set verbose off

break *0xffffffff8110b4f6
break *0xffffffff8110b4c6
break *0xffffffff81f515b3
break *0xffffffff81316acd
break *0xffffffff81132ebe

commands 1-5
where
continue
end

target remote :1234
continue