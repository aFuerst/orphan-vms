import argparse
import pandas as pd
import matplotlib as mpl
mpl.rcParams.update({'font.size': 14})
mpl.use('Agg')
import matplotlib.pyplot as plt
import os

parser = argparse.ArgumentParser()
parser.add_argument('-t', "--trace", required=True, help="ftrace output file")
parser.add_argument('-o', "--out", required=False, default="figs", help="output folder")
args = parser.parse_args()
os.makedirs(args.out, exist_ok=True)

def get_part(parts, key):
    i = parts.index(key)
    return parts[i+1]

pd_data = []
with open(args.trace, "r") as f:
        line = f.readline()
        while line != "":
            if line.startswith(" qemu-system-x86"):
                parts = line.split(" ")
                event = parts[5][:-1]
                if event == "kvm_exit":
                    reason = get_part(parts, "reason")
                    if reason == "EXTERNAL_INTERRUPT":
                        rip = get_part(parts, "rip")
                        info = get_part(parts, "intr_info")
                        timestamp = float(parts[4][:-1])
                        second = float.__floor__(timestamp)
                        steps = 0
                        while True:
                            line = f.readline()
                            parts = line.split(" ")
                            event = parts[5][:-1]
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