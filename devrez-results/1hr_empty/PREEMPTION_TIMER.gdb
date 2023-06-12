
lx-symbols
set pagination off
set logging overwrite on 
set logging file /usr/local/google/home/fuersta/test-vm/devrez-results/1hr_empty/PREEMPTION_TIMER.log
set logging on
set logging redirect on

set width 0
set height 0
set verbose off

break *0xffffffff81c8c091
break *0xffffffff81f49d70
break *0xffffffff81c8bf1f
break *0xffffffff81f45440
break *0xffffffff81103323
break *0xffffffff81c8c088
break *0xffffffff81c8bf16
break *0xffffffff81c8bf36
break *0xffffffff81c8c095
break *0xffffffff81261b90
break *0xffffffff810dfe10
break *0xffffffff81c8c07c
break *0xffffffff811043b5
break *0xffffffff81f49d7b
break *0xffffffff811bd0c4
break *0xffffffff81c8bf44
break *0xffffffff811bd0b0
break *0xffffffff811b8d5c
break *0xffffffff81c8bf52
break *0xffffffff811801f4
break *0xffffffff81c8bf3a
break *0xffffffff81c8bf59
break *0xffffffff81c8bf29
break *0xffffffff811d7b12
break *0xffffffff81c8bf25
break *0xffffffff81f4693d
break *0xffffffff811c0cf7
break *0xffffffff811b8d40
break *0xffffffff81f4693f

commands 1-29
where
continue
end

target remote :1234
continue