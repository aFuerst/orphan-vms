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
        if not is_line(line) and line != "":
            continue
        parts = parse_line(line)
        # try:
        event = get_event(parts)
        # except:
        #     continue
        if event == "kvm_msr":
            # print(parts)
            return parts[6], parts[8][:-1]

read_data = []
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
                    if reason == "MSR_WRITE":
                        rip = get_part(parts, "rip")
                        info = get_part(parts, "intr_info")
                        ecx, data = get_msr_data(f)
                        write_data.append((timestamp, second, rip, info, ecx, data))
                    elif reason == "MSR_READ":
                        rip = get_part(parts, "rip")
                        info = get_part(parts, "intr_info")
                        ecx, data = get_msr_data(f)
                        read_data.append((timestamp, second, rip, info, ecx, data))
            line = f.readline()

read_df = pd.DataFrame.from_records(read_data, columns=["timestamp_raw", "second", "rip", "info", "ecx", "data"])
read_df["timestamp"] = pd.to_datetime(read_df["timestamp_raw"], unit='s')
read_df["minute"] = read_df["second"] // 60

# print("msr reads", read_df.groupby(["rip"]).count().sort_values("second").count())
print("msr reads", read_df.groupby(["ecx"]).count().sort_values("second")["second"].sort_values(ascending=False))

write_df = pd.DataFrame.from_records(write_data, columns=["timestamp_raw", "second", "rip", "info", "ecx", "data"])
write_df["timestamp"] = pd.to_datetime(write_df["timestamp_raw"], unit='s')
write_df["minute"] = write_df["second"] // 60

# print("msr writes", write_df.groupby(["rip"]).count().sort_values("second").count())
print("msr writes", write_df.groupby(["ecx"]).count().sort_values("second")["second"].sort_values(ascending=False))
