
lx-symbols
set pagination off
set logging overwrite on 
set logging file /usr/local/google/home/fuersta/test-vm/exp_scripts/test2_gdb/PREEMPTION_TIMER.log
set logging on
set logging redirect on

set width 0
set height 0
set verbose off

break *0xffffffff81f3dd8b
break *0xffffffff812c6dfd
break *0xffffffff811f7ded
break *0xffffffff81f51536
break *0xffffffff81f515b7
break *0xffffffff815bdfd9
break *0xffffffff815bd499
break *0xffffffff8111cd6b
break *0xffffffff812c80b4
break *0xffffffff815bdfdb
break *0xffffffff81103323
break *0xffffffff8130caa6
break *0xffffffff811776bc
break *0xffffffff8111b430
break *0xffffffff811125dd
break *0xffffffff812ca1f3
break *0xffffffff813157df
break *0xffffffff81334031
break *0xffffffff815bd863
break *0xffffffff81c8bf59
break *0xffffffff81168c12
break *0xffffffff811043b5
break *0xffffffff8115177b
break *0xffffffff811032b0
break *0xffffffff81178de0
break *0xffffffff81175efa
break *0xffffffff81f3dd79
break *0xffffffff815bd49c
break *0xffffffff81180178
break *0xffffffff81178f31
break *0xffffffff81f3dd72
break *0xffffffff81b5a6d1
break *0xffffffff81132ebe
break *0xffffffff81183945
break *0xffffffff81178eef
break *0xffffffff81182c37
break *0xffffffff811bd0b0
break *0xffffffff81f492f6
break *0xffffffff81574eac
break *0xffffffff8116c693
break *0xffffffff815bdf70
break *0xffffffff81175923
break *0xffffffff8118a754
break *0xffffffff81f515a5
break *0xffffffff81189de2
break *0xffffffff811d839d
break *0xffffffff81175e94
break *0xffffffff81f50f57
break *0xffffffff81178e3a
break *0xffffffff81180583
break *0xffffffff81172ed2
break *0xffffffff811032c3
break *0xffffffff8117901d
break *0xffffffff81172eca
break *0xffffffff81175e74
break *0xffffffff81104390
break *0xffffffff81f5160f
break *0xffffffff815fb4b1
break *0xffffffff81153020
break *0xffffffff81f454d6
break *0xffffffff81178d8d
break *0xffffffff811d4980
break *0xffffffff811d4b2c
break *0xffffffff81178eaf
break *0xffffffff81f4958c
break *0xffffffff810dfe10
break *0xffffffff81175872
break *0xffffffff81189dde
break *0xffffffff81172e10
break *0xffffffff81189dee
break *0xffffffff81178e01
break *0xffffffff811bd0c4
break *0xffffffff81174e44
break *0xffffffff81261bad
break *0xffffffff8114f021
break *0xffffffff8114e67d
break *0xffffffff811f50fb
break *0xffffffff815b1390
break *0xffffffff81f3dcbf
break *0xffffffff811ed3f3
break *0xffffffff8117a980

commands 1-81
where
continue
end

target remote :1234
continue