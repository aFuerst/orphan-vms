#!/bin/bash

TIME=1m
OUTFILE="perf.data.$FREQ"
USE_TRACING=false
while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--sleep-time)
      TIME="$2"
      shift
      shift
      ;;
    -t|--tracing)
      USE_TRACING=true
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
      vmx_exit_handlers irq_work_callbacks ttwu_callbacks sync_callbacks non_sync_callbacks unknown_callbacks \
      scheduler_ticks)

sysctl -q -w alex.called_funcs="0 0 0 0 0 0 0 0 0 0"
sysctl -q -w alex.from_cpuid="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
for ctl in "${sysctls[@]}"; do
  sysctl -q -w "alex.$ctl=0"
done

if [[ $USE_TRACING == true ]]; then
echo "0000,1000000" > /sys/kernel/debug/tracing/tracing_cpumask
echo 1 > /sys/kernel/debug/tracing/events/sched/sched_switch/enable
echo 1 > /sys/kernel/debug/tracing/tracing_on
cat /sys/kernel/debug/tracing/trace_pipe > smp_call_fq &
pid=$!
fi

sleep $TIME

for ctl in "${sysctls[@]}"; do
  sysctl "alex.$ctl"
done
sysctl alex.called_funcs
sysctl alex.from_cpuid

if [[ $USE_TRACING == true ]]; then
  echo 0 > /sys/kernel/debug/tracing/tracing_on
  echo 0 > /sys/kernel/debug/tracing/events/sched/sched_switch/enable
  kill $pid
fi
