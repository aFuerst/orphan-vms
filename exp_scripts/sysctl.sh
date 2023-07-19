#!/bin/bash

TIME=1m
OUTFILE="perf.data.$FREQ"
while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--sleep-time)
      TIME="$2"
      shift
      shift
      ;;
    -o|--out-file)
      OUTFILE="$2"
      shift
      shift
      ;;
    *)
        echo "Unknown argument $1"
        exit 1
      ;;
  esac
done

sysctls=(call_function_single call_functions handled_interrupts local_apic reschedule_ipis \
      handled_function_vector handled_reschedule handled_function_single_vector handled_local_timer handled_other_interrupt \
      slow_exit_break slow_exit_irq_injection slow_exit_loop slow_exit_timer slow_exit_xfer_guest_mode slow_exits \
      exit_msr_interrupt_window exit_msr_write exit_msr_read exit_apic_write exit_interrupt exit_nmi exit_other \
      vmx_exit_handlers)

for ctl in "${sysctls[@]}"; do
  sysctl -q -w "alex.$ctl=0"
done

# sysctl -q -w alex.call_function_single=0
# sysctl -q -w alex.call_functions=0
# sysctl -q -w alex.handled_interrupts=0
# sysctl -q -w alex.local_apic=0
# sysctl -q -w alex.reschedule_ipis=0 
# sysctl -q -w alex.handled_function_vector=0
# sysctl -q -w alex.handled_reschedule=0
# sysctl -q -w alex.handled_function_single_vector=0
# sysctl -q -w alex.handled_local_timer=0
# sysctl -q -w alex.handled_other_interrupt=0

# sysctl -q -w alex.slow_exit_break=0
# sysctl -q -w alex.slow_exit_irq_injection=0
# sysctl -q -w alex.slow_exit_loop=0
# sysctl -q -w alex.slow_exit_timer=0
# sysctl -q -w alex.slow_exit_xfer_guest_mode=0
# sysctl -q -w alex.slow_exits=0

sleep $TIME

for ctl in "${sysctls[@]}"; do
  sysctl "alex.$ctl"
done


# sysctl alex.call_function_single
# sysctl alex.call_functions
# sysctl alex.handled_interrupts
# sysctl alex.local_apic
# sysctl alex.reschedule_ipis
# sysctl alex.handled_function_vector
# sysctl alex.handled_reschedule
# sysctl alex.handled_function_single_vector
# sysctl alex.handled_local_timer
# sysctl alex.handled_other_interrupt

# sysctl alex.slow_exit_break
# sysctl alex.slow_exit_irq_injection
# sysctl alex.slow_exit_loop
# sysctl alex.slow_exit_timer
# sysctl alex.slow_exit_xfer_guest_mode
# sysctl alex.slow_exits
