set pagination off
set logging overwrite on 
set logging file ./offlining.log
set logging on
set logging redirect on


lx-symbols

# break takedown_cpu
# break take_cpu_down
# break cpuhp_invoke_callback
# break cpuhp_invoke_ap_callback
# break cpu_subsys_offline
# break device_offline
# break _cpu_down
# break cpu_report_death
# break native_play_dead
# break mwait_play_dead
# break hlt_play_dead
# break jmp_vmm_vcpu
break kernel/cpu.c:192

#1       breakpoint     keep y   0xffffffff8112f1b0 in takedown_cpu at kernel/cpu.c:1059
#2       breakpoint     keep y   <MULTIPLE>
#2.1                         y   0xffffffff819335e0 in device_offline at drivers/base/core.c:4112
#2.2                         y   0xffffffff81933666 in device_offline at ./include/linux/device.h:837
#3       breakpoint     keep y   0xffffffff81163f40 in cpu_report_death at kernel/smpboot.c:474
#4       breakpoint     keep y   0xffffffff8112fc36 in __cpu_disable at ./arch/x86/include/asm/smp.h:88
#5       breakpoint     keep y   0xffffffff8112fc30 in take_cpu_down at kernel/cpu.c:1028
#6       breakpoint     keep y   0xffffffff812145b0 in stop_machine_cpuslocked at kernel/stop_machine.c:588
#7       breakpoint     keep y   0xffffffff812140e0 in multi_cpu_stop at kernel/stop_machine.c:204
#8       breakpoint     keep y   0xffffffff81104040 in native_play_dead at arch/x86/kernel/smpboot.c:1840

commands 1-1
print cb
continue
end

# echo 0 > /sys/devices/system/cpu/cpu3/online
target remote :1234
continue