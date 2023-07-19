#!/bin/bash

TIME=1m
FREQ=13
OUTFILE="perf.data.$FREQ"
CUST_FILE=false
CORE=24
PID=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --pid)
        PID="$2"
        shift
        shift
      ;;
    --core)
      CORE="$2"
      shift
      shift
      ;;
    -f|--frequency)
      FREQ="$2"
      if [[ $CUST_FILE != true ]]; then
        OUTFILE="perf.data.$FREQ"
      fi
      shift
      shift
      ;;
    -s|--sleep-time)
      TIME="$2"
      shift
      shift
      ;;
    -o|--out-file)
      OUTFILE="$2"
      CUST_FILE=true
      shift
      shift
      ;;
    *)
        echo "Unknown argument $1"
        exit 1
      ;;
  esac
done

if [[ -n "$PID" ]]; then
  perf5 record -F $FREQ -s --pid $PID -g -o $OUTFILE -- sleep $TIME
else
  perf5 record -F $FREQ --cpu $CORE -g -o $OUTFILE -- sleep $TIME
fi
# perf5 report -i $outfile

# perf5 kvm --host stat record -o perf.test &
# perf_pid=$!

# cleanup() {
#   kill -s SIGINT $perf_pid
#   sleep 5s
#   perf5 kvm -i perf.test --host stat report > perf.report
#   cat perf.report
#   echo "Perf done"
#   exit 0
# }
# trap cleanup SIGINT


# sleep $TIME
# cleanup
