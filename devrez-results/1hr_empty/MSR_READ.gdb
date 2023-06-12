
lx-symbols
set pagination off
set logging overwrite on 
set logging file /usr/local/google/home/fuersta/test-vm/devrez-results/1hr_empty/MSR_READ.log
set logging on
set logging redirect on

set width 0
set height 0
set verbose off

break *0xffffffff81103321
break *0xffffffff810f5b03
break *0xffffffff81f43be1
# Hardware assisted breakpoint 9 at 0xffffffff81103321: file arch/x86/kernel/smpboot.c, line 1264.
# Hardware assisted breakpoint 10 at 0xffffffff810f5b03: file arch/x86/kernel/cpu/mce/core.c, line 2393.
# Hardware assisted breakpoint 11 at 0xffffffff81f43be1: file arch/x86/kernel/irq.c, line 391

commands 1-3
where
continue
end

target remote :1234
continue