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
hypercall_data = []
with open(args.trace, "r") as f:
        line = f.readline()
        while line != "":
            if line.startswith(" qemu-system-x86"):
                parts = line.split(" ")
                event = parts[5][:-1]
                timestamp = float(parts[4][:-1])
                second = float.__floor__(timestamp)
                if event == "kvm_exit":
                    reason = get_part(parts, "reason")
                    if reason == "HLT":
                        vcpu = get_part(parts, "vcpu")
                        rip = get_part(parts, "rip")
                        info1 = get_part(parts, "info1")
                        info2 = get_part(parts, "info2")
                        intr = get_part(parts, "intr_info")
                        error_code = get_part(parts, "error_code")
                        pd_data.append((timestamp, second, rip, info1, info2, intr, error_code, vcpu))
            line = f.readline()

df = pd.DataFrame.from_records(pd_data, columns=["timestamp_raw", "second", "rip", "info1", "info2", "intr", "error_code", "vcpu"])
df["timestamp"] = pd.to_datetime(df["timestamp_raw"], unit='s')
df["minute"] = df["second"] // 60

print(df.groupby(["rip"]).count())
