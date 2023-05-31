
lx-symbols
set pagination off
set logging overwrite on 
set logging file /usr/local/google/home/fuersta/test-vm/exp_scripts/test2_gdb/INTERRUPT_WINDOW.log
set logging on
set logging redirect on

set width 0
set height 0
set verbose off

break *0xffffffff81f512af
break *0xffffffff81f4693f
break *0xffffffff81f50f57
break *0xffffffff811ed8a6
break *0xffffffff8111cb79
break *0xffffffff81f50f1f
break *0xffffffff8117ab84
break *0xffffffff81169adb
break *0xffffffff8114f369
break *0xffffffff81175c84

commands 1-10
where
continue
end

target remote :1234
continue