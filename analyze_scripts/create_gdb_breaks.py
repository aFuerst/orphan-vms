import argparse
import pandas as pd
from collections import defaultdict
from ftrace import *
import os

parser = argparse.ArgumentParser()
parser.add_argument('-t', "--trace", required=True, help="ftrace output file")
parser.add_argument('-f', "--out-folder", required=True, help="gdb breakpoints output folder to create")
args = parser.parse_args()

os.makedirs(args.out_folder, exist_ok=True)

pd_data = []
def parse_file():
    with open(args.trace, "r") as f:
        line = f.readline()
        while line != "":
            if is_line(line):
                parts = parse_line(line)
                timestamp, second = get_timestamp(parts)

                event = get_event(parts)
                if event == "kvm_exit":
                    rip = get_part(parts, "rip")
                    reason = get_part(parts, "reason")
                    if rip != MISSING_PART and reason != MISSING_PART:
                        pd_data.append((timestamp, second, reason, rip))
            line = f.readline()

parse_file()

df = pd.DataFrame.from_records(pd_data, columns=["timestamp_raw", "second", "reason", "rip"])
df["timestamp"] = pd.to_datetime(df["timestamp_raw"], unit='s')
df["minute"] = df["second"] // 60

for name, group in df.groupby("reason"):
    to_write = []
    for address in group["rip"].unique():
        if address.startswith("0xff"):
            to_write.append(f"break *{address}\n")

    if len(to_write) > 0:
        logfile = os.path.join(args.out_folder, f"{name}.log")
        logfile = os.path.abspath(logfile)
        print(logfile)
        with open(os.path.join(args.out_folder, f"{name}.gdb"), "w") as f:
            f.write(f"\n\
lx-symbols\n\
set pagination off\n\
set logging overwrite on \n\
set logging file {logfile}\n\
set logging on\n\
set logging redirect on\n\
\n\
set width 0\n\
set height 0\n\
set verbose off\n\
\n")
            f.writelines(to_write)

            f.write(f"\n\
commands 1-{len(to_write)}\n\
where\n\
continue\n\
end\n\
\n\
target remote :1234\n\
continue")
