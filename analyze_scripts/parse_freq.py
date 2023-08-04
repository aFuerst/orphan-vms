import argparse
import pandas as pd
import matplotlib as mpl
mpl.rcParams.update({'font.size': 14})
mpl.use('Agg')
import matplotlib.pyplot as plt
from collections import defaultdict
from pprint import pprint
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument('-t', "--trace", required=True, help="ftrace output file")
args = parser.parse_args()

ran = defaultdict(int)
ran_pids = defaultdict(set)
accumulated_time = defaultdict(float)

deltas = []

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
# <...>-30443   [024] d.h..  2153.944047: clockevents_program_event: seting clock event using lapic_next_deadline+0x0/0x50 with delta 230015390
with open(args.trace) as f:
    for line in f.readlines():
        if "clockevents_program_event" in line:
            parts = line.split()
            for i, p in enumerate(parts):
                if p == "delta":
                    try:
                        deltas.append(int(parts[i+1]))
                    except Exception as e:
                        print(line)
                        raise e

            # for l2 in l2s:
            #     if "clockevents_program_event" in l2:

            #         parts = l2.split()
            #         try:
            #             deltas.append(int(parts[-1]))
            #         except Exception as e:
            #             print(l2)
            #             raise e
                # curr_t = get_time(parts)
                # if last_sched_t is None:
                #     last_sched_t = curr_t

                # next = get_prev_comm(parts)
                # elapsed = curr_t - last_sched_t
                # ran[next] += 1
                # pid = get_prev_pid(parts)
                # ran_pids[next].add(pid)
                # accumulated_time[next] += elapsed
                # last_sched_t = curr_t

# pprint(ran)
# pprint(accumulated_time)
# pprint(ran_pids)

print(np.min(deltas), np.mean(deltas), np.max(deltas), np.std(deltas), np.quantile(deltas, [0.5]))