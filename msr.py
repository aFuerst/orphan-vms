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

def get_msr_data(f):
    while True:
        line = f.readline()
        parts = line.split(" ")
        event = parts[5][:-1]
        if event == "kvm_msr":
            return parts[7], parts[9][:-1]

read_data = []
write_data = []
with open(args.trace, "r") as f:
        line = f.readline()
        while line != "":
            if line.startswith(" qemu-system-x86"):
                parts = line.split(" ")
                event = parts[5][:-1]
                if event == "kvm_exit":
                    reason = get_part(parts, "reason")
                    if reason == "MSR_WRITE":
                        rip = get_part(parts, "rip")
                        info = get_part(parts, "intr_info")
                        timestamp = float(parts[4][:-1])
                        second = float.__floor__(timestamp)
                        ecx, data = get_msr_data(f)
                        write_data.append((timestamp, second, rip, info))
                    elif reason == "MSR_READ":
                        rip = get_part(parts, "rip")
                        info = get_part(parts, "intr_info")
                        timestamp = float(parts[4][:-1])
                        second = float.__floor__(timestamp)
                        ecx, data = get_msr_data(f)
                        read_data.append((timestamp, second, rip, info))
            line = f.readline()

df = pd.DataFrame.from_records(read_data, columns=["timestamp_raw", "second", "rip", "info"])
df["timestamp"] = pd.to_datetime(df["timestamp_raw"], unit='s')
df["minute"] = df["second"] // 60

print("msr reads", df.groupby(["rip"]).count().sort_values("second").count())

df = pd.DataFrame.from_records(write_data, columns=["timestamp_raw", "second", "rip", "info"])
df["timestamp"] = pd.to_datetime(df["timestamp_raw"], unit='s')
df["minute"] = df["second"] // 60

print("msr writes", df.groupby(["rip"]).count().sort_values("second").count())
