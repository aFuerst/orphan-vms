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

callsite = defaultdict(int)
callback = defaultdict(int)
interrupt_vec = defaultdict(int)
interrupt_vec_int = defaultdict(int)

with open(args.trace) as f:
    for line in f.readlines():
        if "ipi_send_cpu" in line:
            parts = line.split()
            for p in parts:
                if "callsite" in p:
                    callsite[p.split("=")[1].split('+')[0]] += 1
                if "callback" in p:
                    callback[p.split("=")[1].split('+')[0]] += 1

        if "handle_external_interrupt_irqoff" in line:
            vector = line.split(' ')[-1].strip()
            vec_int = int(vector, 16)
            interrupt_vec[vector] += 1
            interrupt_vec_int[vec_int] += 1


pprint([item for item in sorted(callback.items(), key=lambda x: x[1], reverse=True)])
pprint([item for item in sorted(callsite.items(), key=lambda x: x[1], reverse=True)])

pprint(interrupt_vec)
pprint(interrupt_vec_int)