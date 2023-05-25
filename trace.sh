#!/bin/bash
# Run with sudo

TIME=1m
OUTDIR="."
while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--sleep-time)
      TIME="$2"
      shift
      shift
      ;;
    -o|--out-folder)
      OUTDIR="$2"
      shift
      shift
      ;;
    *)
      shift
      ;;
  esac
done

cleanup() {
  echo 0 > "/sys/kernel/tracing/events/kvm/enable"
  echo "Trace done"
  exit 0
}
trap cleanup SIGINT

# empty current trace buffer
> "/sys/kernel/tracing/trace"

# grow buffer to hold more info
old_cpu_buff_size=$(cat /sys/kernel/tracing/buffer_size_kb)
echo 10000 > /sys/kernel/tracing/buffer_size_kb

KVM_EVENTS=(
    kvm_exit
    kvm_msr 
    kvm_cpuid 
    kvm_hypercall
    kvm_page_fault 
    kvm_invlpga 
    kvm_vcpu_wakeup
    )
# enable tracing KVM VM events
# for EVENT in "${KVM_EVENTS[@]}"; do
#    echo 1 > "/sys/kernel/tracing/events/kvm/$EVENT/enable"
# done
echo 1 > "/sys/kernel/tracing/events/kvm/enable"

outfile="$OUTDIR/vm_exits.out"
> $outfile # empty file
# background cat pipes events to file as they come in, avoiding loss
cat /sys/kernel/tracing/trace_pipe >> $outfile &
cat_pid=$!

sleep $TIME

# disable KVM VM events

# for EVENT in "${KVM_EVENTS[@]}"; do
#    echo 0 > "/sys/kernel/tracing/events/kvm/$EVENT/enable"
# done
cleanup
kill $cat_pid
