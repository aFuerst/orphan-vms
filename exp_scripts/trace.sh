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
  echo "bacjup"
  SYS_TRACE_DIR="/sys/kernel/debug/tracing"
fi

# enable tracing
echo 1 > $SYS_TRACE_DIR/tracing_on
echo "nop" > $SYS_TRACE_DIR/current_tracer

# empty current trace buffer
> "$SYS_TRACE_DIR/trace"

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

outfile="$OUTDIR/vm_exits.out"
> $outfile # empty file
# background cat pipes events to file as they come in, avoiding loss
cat $SYS_TRACE_DIR/trace_pipe >> $outfile &
cat_pid=$!

cleanup() {
  echo 0 > "$SYS_TRACE_DIR/events/kvm/enable"
  kill $cat_pid
  echo "Trace done"
  exit 0
}
trap cleanup SIGINT


sleep $TIME

# disable KVM VM events
# for EVENT in "${KVM_EVENTS[@]}"; do
#    echo 0 > "$SYS_TRACE_DIR/events/kvm/$EVENT/enable"
# done
cleanup
