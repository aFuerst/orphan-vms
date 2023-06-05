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
args = parser.parse_args()

def get_msr_data(f):
    while True:
        line = f.readline()
        parts = parse_line(line)
        event = get_event(parts)
        if event == "kvm_apic":
            return parts[6], parts[8][:-1]

write_data = []
with open(args.trace, "r") as f:
        line = f.readline()
        while line != "":
            if is_line(line):
                parts = parse_line(line)
                event = get_event(parts)
                if event == "kvm_exit":
                    reason = get_part(parts, "reason")
                    timestamp, second = get_timestamp(parts)
                    if reason == "APIC_WRITE":
                        rip = get_part(parts, "rip")
                        info = get_part(parts, "intr_info")
                        target, data = get_msr_data(f)
                        write_data.append((timestamp, second, rip, info, target, data))
            line = f.readline()

write_df = pd.DataFrame.from_records(write_data, columns=["timestamp_raw", "second", "rip", "info", "target", "data"])
write_df["timestamp"] = pd.to_datetime(write_df["timestamp_raw"], unit='s')
write_df["minute"] = write_df["second"] // 60

print("APIC writes", write_df.groupby(["target"]).count().sort_values("second")["second"].sort_values(ascending=False))