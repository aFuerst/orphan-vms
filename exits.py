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
            if parts[5][:-1] == "kvm_exit":
                reason = get_part(parts, "reason")
                cpu = parts[2]
                timestamp = float(parts[4][:-1])
                second = float.__floor__(timestamp)
                cpu = parts[2][1:-1]
                vcpu = get_part(parts, "vcpu")
                rip = get_part(parts, "rip")
                info1 = get_part(parts, "info1")
                info2 = get_part(parts, "info2")
                intr_info = get_part(parts, "intr_info")
                error = get_part(parts, "error_code")[:-1]
                pd_data.append((timestamp, second, reason, cpu, vcpu, info1, info2, intr_info, error))

df = pd.DataFrame.from_records(pd_data, columns=["timestamp_raw", "second", "reason", "cpu", "vcpu", "info1", "info2", "intr_info", "error"])
df["timestamp"] = pd.to_datetime(df["timestamp_raw"], unit='s')
df["minute"] = df["second"] // 60

def plot_all():
    fig, ax = plt.subplots()
    groups = df.groupby("reason").count()["timestamp"]
    ticks = [i for i in range(len(groups))]
    ax.barh(ticks, width=groups)
    ax.set_yticks(ticks)
    ax.set_yticklabels(groups.index)
    ax.set_xscale("log")
    ax.set_xlabel("# VM Exits")
    plt.savefig(os.path.join(args.out, "exits.png"), bbox_inches="tight")

def plot_frequency():
    fig, ax = plt.subplots()
    all_exits = df.groupby("second").count()["timestamp"]
    xs = (all_exits.index.to_numpy() - all_exits.index[0])
    ax.plot(xs, all_exits, label="All")

    for reason in sorted(df["reason"].unique()):
        all_exits = df[df["reason"]==reason].groupby("second").count()["timestamp"]
        xs = (all_exits.index.to_numpy() - all_exits.index[0])
        ax.plot(xs, all_exits, label=reason)
    ax.legend(loc=(1,0))
    plt.savefig(os.path.join(args.out, "exit_frequency.png"), bbox_inches="tight")

def plot(reason, data, fname, label, scale=None):
    ept = df[df["reason"]==reason]
    if len(ept) == 0:
        return
    fig, ax = plt.subplots()
    groups = ept.groupby(data).count()["timestamp"]
    ticks = [i for i in range(len(groups))]
    ax.barh(ticks, width=groups)
    ax.set_yticks(ticks)
    ax.set_yticklabels(groups.index)
    if scale is not None:
        ax.set_xscale(scale)
    ax.set_xlabel(label)
    plt.savefig(os.path.join(args.out, fname), bbox_inches="tight")

def plot_ept():
    plot("EPT_VIOLATION", "info1", "ept-info1.png", "info1 value", "log")
    plot("EPT_VIOLATION", "info2", "ept-info2.png", "info2 value", "log")

def plot_external():
    plot("EXTERNAL_INTERRUPT", "intr_info", "int-intr_info.png", "intr_info value", "log")

def plot_hlt():
    plot("HLT", "vcpu", "hlt-vcpu.png", "vcpu count")

def plot_io():
    plot("IO_INSTRUCTION", "info1", "io-info1.png", "info1 count")

print("Avg VM exits per second:", df.groupby("second").count().mean()["timestamp"])
print(df.groupby("reason").count()["timestamp"])
plot_frequency()
plot_all()
plot_ept()
plot_hlt()
plot_external()
plot_io()