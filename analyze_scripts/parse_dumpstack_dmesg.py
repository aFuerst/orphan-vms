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

comms = defaultdict(int)
pids_to_comm = defaultdict(set)

def get_pid(parts):
    return parts[parts.index("PID:")+1]

def get_comm(parts):
    return parts[parts.index("Comm:")+1]

# [  768.640187] CPU: 1 PID: 8957 Comm: sla_test Tainted: G S                 6.4.0-smp-DEV #20
with open(args.trace) as f:
    for line in f.readlines():
        if "CPU:" in line:
            parts = line.split()
            comm = get_comm(parts)
            pid = get_pid(parts)
            comms[comm] += 1
            pids_to_comm[comm].add(pid)

pprint(comms)
pprint(pids_to_comm)