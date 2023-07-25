import argparse
import pandas as pd
import matplotlib as mpl
mpl.rcParams.update({'font.size': 14})
mpl.use('Agg')
import matplotlib.pyplot as plt
from collections import defaultdict
from pprint import pprint

parser = argparse.ArgumentParser()
parser.add_argument('-t', "--trace", required=True, help="ftrace output file")
args = parser.parse_args()

sync = defaultdict(int)
non_sync = defaultdict(int)
ttwu = defaultdict(int)
irq_work = defaultdict(int)
from_cpuid = defaultdict(int)
to_cpuid = defaultdict(int)
func_from = defaultdict(lambda: defaultdict(int))

def get_func(parts):
    return parts[-1].split('+')[0]

def get_from(parts):
    return int(parts[parts.index("from:")+1].strip("';"))

def get_to(parts):
    return int(parts[parts.index("to:")+1].strip("';"))

# trace_printk("executing non-sync callback from: '%d' to: '%d' %pS\n", src, dst, csd->func);
with open(args.trace) as f:
    for line in f.readlines():
        parts = line.split()
        to = get_to(parts)
        name = get_func(parts)
        from_cpuid[get_from(parts)] += 1
        to_cpuid[to] += 1
        func_from[name][get_from(parts)] += 1
        if "executing non-sync callback" in line:
            non_sync[name] += 1
        elif "executing sync callback" in line:
            sync[name] += 1
        elif "executing ttwu callback" in line:
            ttwu[name] += 1
        elif "executing irq work callback" in line:
            irq_work[name] += 1

print("non-sync", [item for item in sorted(sync.items(), key=lambda x: x[1], reverse=True)])
print("sync", [item for item in sorted(non_sync.items(), key=lambda x: x[1], reverse=True)])
print("ttwu", [item for item in sorted(ttwu.items(), key=lambda x: x[1], reverse=True)])
print("irq_work", [item for item in sorted(irq_work.items(), key=lambda x: x[1], reverse=True)])

# pprint([item for item in sorted(from_cpuid.items(), key=lambda x: x[1], reverse=True)])
# pprint([item for item in sorted(to_cpuid.items(), key=lambda x: x[1], reverse=True)])

for func, data in func_from.items():
    print(func, sorted(data.items(), key=lambda x: x[0]))