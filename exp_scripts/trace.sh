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

SYS_TRACE_DIR="/sys/kernel/tracing"
if [ ! -f "$SYS_TRACE_DIR/tracing_on" ]; then
  SYS_TRACE_DIR="/sys/kernel/debug/tracing"
fi

# enable tracing
echo 1 > $SYS_TRACE_DIR/tracing_on
echo "nop" > $SYS_TRACE_DIR/current_tracer

# grow buffer to hold more info
old_cpu_buff_size=$(cat $SYS_TRACE_DIR/buffer_size_kb)
echo 10000 > $SYS_TRACE_DIR/buffer_size_kb

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
#    echo 1 > "$SYS_TRACE_DIR/events/kvm/$EVENT/enable"
# done
echo 1 > "$SYS_TRACE_DIR/events/kvm/enable"
echo 1 > "$SYS_TRACE_DIR/events/sched/sched_wakeup/enable"
echo "target_cpu == 24" > "$SYS_TRACE_DIR/events/sched/sched_wakeup/filter"
echo 1 > "$SYS_TRACE_DIR/events/sched/sched_waking/enable"
echo "target_cpu == 24" > "$SYS_TRACE_DIR/events/sched/sched_waking/filter"
echo "cpu == 24" > /sys/kernel/debug/tracing/events/ipi/ipi_send_cpu/filter
echo 1 > /sys/kernel/debug/tracing/events/ipi/ipi_send_cpu/enable

# empty current trace buffer
> "$SYS_TRACE_DIR/trace"

outfile="$OUTDIR/vm_exits.out"
> $outfile # empty file
# background cat pipes events to file as they come in, avoiding loss
cat $SYS_TRACE_DIR/trace_pipe >> $outfile &
cat_pid=$!

cleanup() {
  echo 0 > "$SYS_TRACE_DIR/events/kvm/enable"
  echo 0 > "$SYS_TRACE_DIR/events/sched/sched_wakeup/enable"
  echo 0 > "$SYS_TRACE_DIR/events/sched/sched_waking/enable"
  echo 0 > /sys/kernel/debug/tracing/events/ipi/ipi_send_cpu/enable
  kill $cat_pid
  echo "Trace done"
  exit 0
}
trap cleanup SIGINT


sleep $TIME
# ch-remote --api-socket /tmp/cloud-hypervisor.sock orphan

# sleep $TIME
# ch-remote --api-socket /tmp/cloud-hypervisor.sock adopt

# sleep $TIME

# disable KVM VM events
# for EVENT in "${KVM_EVENTS[@]}"; do
#    echo 0 > "$SYS_TRACE_DIR/events/kvm/$EVENT/enable"
# done
cleanup
