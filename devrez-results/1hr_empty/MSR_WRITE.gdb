
lx-symbols
set pagination off
set logging overwrite on 
set logging file /usr/local/google/home/fuersta/test-vm/devrez-results/1hr_empty/MSR_WRITE.log
set logging on
set logging redirect on

set width 0
set height 0
set verbose off

break *0xffffffff811043b3

commands 1-1
where
continue
end

target remote :1234
continue