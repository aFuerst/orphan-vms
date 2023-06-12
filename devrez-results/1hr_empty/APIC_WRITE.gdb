
lx-symbols
set pagination off
set logging overwrite on 
set logging file /usr/local/google/home/fuersta/test-vm/devrez-results/1hr_empty/APIC_WRITE.log
set logging on
set logging redirect on

set width 0
set height 0
set verbose off

break *0xffffffff8110b4cc
break *0xffffffff8110c50c
break native_apic_mem_write

commands 1-1
where
continue
end

target remote /tmp/ch-gdb.sock
# continue