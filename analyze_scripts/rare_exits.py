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

def get_inj_virq(f):
    while True:
        line = f.readline()
        parts = line.split(" ")
        event = parts[5][:-1]
        if event == "kvm_inj_virq":
            timestamp = float(parts[4][:-1])
            second = float.__floor__(timestamp)
            interrupt_type = parts[6]
            interrupt_bytes = parts[7][:-1]
            return timestamp, second, interrupt_type, interrupt_bytes
        if event == "kvm_entry":
            return None
preempt_data = []
preempt_inject = []
intr_window_data = []
injected_rupts = []
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
                    vcpu = get_part(parts, "vcpu")
                    rip = get_part(parts, "rip")
                    info1 = get_part(parts, "info1")
                    info2 = get_part(parts, "info2")
                    intr = get_part(parts, "intr_info")
                    error_code = get_part(parts, "error_code")
                    if reason == "PREEMPTION_TIMER":
                        preempt_data.append((timestamp, second, rip, info1, info2, intr, error_code, vcpu))
                        r = get_inj_virq(f)
                        if r is not None:
                            preempt_inject.append(r)
                    if reason == "INTERRUPT_WINDOW":
                        intr_window_data.append((timestamp, second, rip, info1, info2, intr, error_code, vcpu))
                        r = get_inj_virq(f)
                        if r is not None:
                            injected_rupts.append(r)
            line = f.readline()

df = pd.DataFrame.from_records(preempt_data, columns=["timestamp_raw", "second", "rip", "info1", "info2", "intr", "error_code", "vcpu"])
df["timestamp"] = pd.to_datetime(df["timestamp_raw"], unit='s')
df["minute"] = df["second"] // 60

print("PREEMPTION_TIMER ", df.groupby(["rip"]).count())
df = pd.DataFrame.from_records(preempt_inject, columns=["timestamp_raw", "second", "interrupt_type", "interrupt_vec"])
df["timestamp"] = pd.to_datetime(df["timestamp_raw"], unit='s')
df["minute"] = df["second"] // 60
print(df.groupby("interrupt_vec").count())


df = pd.DataFrame.from_records(intr_window_data, columns=["timestamp_raw", "second", "rip", "info1", "info2", "intr", "error_code", "vcpu"])
df["timestamp"] = pd.to_datetime(df["timestamp_raw"], unit='s')
df["minute"] = df["second"] // 60

print("INTERRUPT_WINDOW", df.groupby(["rip"]).count())
df = pd.DataFrame.from_records(injected_rupts, columns=["timestamp_raw", "second", "interrupt_type", "interrupt_vec"])
df["timestamp"] = pd.to_datetime(df["timestamp_raw"], unit='s')
df["minute"] = df["second"] // 60
print(df.groupby("interrupt_vec").count())
