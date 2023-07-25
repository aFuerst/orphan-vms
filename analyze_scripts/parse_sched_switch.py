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

ran = defaultdict(int)
ran_pids = defaultdict(set)
accumulated_time = defaultdict(float)

def get_prev_comm(parts):
    for p in parts:
        if "prev_comm" in p:
            _, proc = p.split('=')
            return proc
    raise Exception("no prev_comm found")


def get_prev_pid(parts):
    for p in parts:
        if "prev_pid" in p:
            _, pid = p.split('=')
            return int(pid)
    raise Exception("no prev_pid found")

def get_time(parts):
    try:
        idx = parts.index("sched_switch:")
        return float(parts[idx-1][:-1])
    except Exception as e:
        print(parts)
        raise e

last_sched_t = None
# Streamz_RPC-10404   [024] d.... 424658.012740: sched_switch: prev_comm=Streamz_RPC prev_pid=10404 prev_prio=120 prev_state=S ==> next_comm=vcpu0 next_pid=12133 next_prio=120
with open(args.trace) as f:
    for line in f.readlines():
        if "sched_switch" in line:
            parts = line.split()
            curr_t = get_time(parts)
            if last_sched_t is None:
                last_sched_t = curr_t

            next = get_prev_comm(parts)
            elapsed = curr_t - last_sched_t
            ran[next] += 1
            pid = get_prev_pid(parts)
            ran_pids[next].add(pid)
            accumulated_time[next] += elapsed
            last_sched_t = curr_t

pprint(ran)
pprint(accumulated_time)
pprint(ran_pids)