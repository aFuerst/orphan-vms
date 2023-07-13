import argparse
import pandas as pd
import matplotlib as mpl
mpl.rcParams.update({'font.size': 14})
mpl.use('Agg')
import matplotlib.pyplot as plt
import os
from ftrace import *

parser = argparse.ArgumentParser()
parser.add_argument('-t', "--trace", required=True, help="ftrace output file")
parser.add_argument('-o', "--out", required=False, default="figs", help="output folder")
args = parser.parse_args()
os.makedirs(args.out, exist_ok=True)

pd_data = []
with open(args.trace, "r") as f:
        line = f.readline()
        while line != "":
            if is_line(line):
                parts = parse_line(line)
                event = get_event(parts)
                if event == "kvm_exit":
                    reason = get_part(parts, "reason")
                    if reason == "EXTERNAL_INTERRUPT":
                        rip = get_part(parts, "rip")
                        info = get_part(parts, "intr_info")
                        timestamp, second = get_timestamp(parts)
                        steps = 0
                        while True:
                            line = f.readline()
                            parts = parse_line(line)
                            event = get_event(parts)
                            if event != "kvm_entry":
                                steps += 1
                            else:
                                break
                        pd_data.append((timestamp, second, rip, info, steps))

            line = f.readline()

df = pd.DataFrame.from_records(pd_data, columns=["timestamp_raw", "second", "rip", "info", "steps"])
df["timestamp"] = pd.to_datetime(df["timestamp_raw"], unit='s')
df["minute"] = df["second"] // 60

print(df.groupby(["rip"]).count().sort_values("second"))
print(df.groupby(["info"]).count())

# print(df[df["steps"] == df["steps"].max()])