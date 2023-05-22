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
    for line in f.readlines():
        if line.startswith(" qemu-system-x86"):
            parts = line.split(" ")
            event = parts[5][:-1]
            if not event.startswith("kvm_"):
                print(line)
                continue
            timestamp = float(parts[4][:-1])
            second = float.__floor__(timestamp)
            pd_data.append((timestamp, second, event))

df = pd.DataFrame.from_records(pd_data, columns=["timestamp_raw", "second", "event"])
df["timestamp"] = pd.to_datetime(df["timestamp_raw"], unit='s')
df["minute"] = df["second"] // 60

print(df["event"].describe())

def plot_events():
    fig, ax = plt.subplots()
    groups = df.groupby("event").count()["timestamp"]
    ticks = [i for i in range(len(groups))]
    ax.barh(ticks, width=groups)
    ax.set_yticks(ticks)
    ax.set_yticklabels(groups.index)
    ax.set_xscale("log")
    ax.set_xlabel("# VM Events of type")
    plt.savefig(os.path.join(args.out, "events.png"), bbox_inches="tight")

plot_events()