import argparse
import pandas as pd
from collections import defaultdict

parser = argparse.ArgumentParser()
parser.add_argument('-t', "--trace", required=True, help="ftrace output file")
args = parser.parse_args()

def get_part(parts, key):
    i = parts.index(key)
    return parts[i+1]

pd_data = []
instruction_data = []
orders = defaultdict(lambda: defaultdict(int))
def parse_file():
    with open(args.trace, "r") as f:
        line = f.readline()
        while line != "":
            if line.startswith(" qemu-system-x86"):
                parts = line.split(" ")
                timestamp = float(parts[4][:-1])
                second = float.__floor__(timestamp)

                event = parts[5][:-1]
                if event == "kvm_exit":
                    pd_data.append((timestamp, second, event))
                    reason = get_part(parts, "reason")
                    if reason == "EPT_VIOLATION":
                        passed_events = []
                        rip = None
                        event_cnt = 0
                        while event != "kvm_entry":
                            old_event = event
                            line = f.readline()
                            if line == "":
                                return
                            parts = line.split(" ")
                            event = parts[5][:-1]

                            if old_event == event:
                                event_cnt += 1
                                if event_cnt > 1:
                                    continue
                            elif event_cnt > 1:
                                passed_events.append(f"{old_event}*{event_cnt}")
                            elif event_cnt <= 1:
                                passed_events.append(f"{old_event}")
                                pass

                            if event == "kvm_emulate_insn":
                                timestamp = float(parts[4][:-1])
                                second = float.__floor__(timestamp)
                                parts = line.split(":")
                                instruction = parts[-1][:-len(" (prot64)\n")]
                                rip = parts[3]
                                instruction_data.append((timestamp, second, rip, instruction))
                            if event == "kvm_apic":
                                event = event = parts[6]
                        if rip is not None:
                            orders[rip][", ".join(passed_events)] += 1
            line = f.readline()

parse_file()

df = pd.DataFrame.from_records(pd_data, columns=["timestamp_raw", "second", "event"])
df["timestamp"] = pd.to_datetime(df["timestamp_raw"], unit='s')
df["minute"] = df["second"] // 60

instr_df = pd.DataFrame.from_records(instruction_data, columns=["timestamp_raw", "second", "rip", "instruction"])
instr_df["timestamp"] = pd.to_datetime(instr_df["timestamp_raw"], unit='s')
instr_df["minute"] = df["second"] // 60

for rip in orders.keys():
    print(rip)
    for events,cnt in orders[rip].items():
        print(cnt, events)

    sub_df = instr_df[instr_df["rip"]==rip]
    print("emu instr {}\n".format(sub_df["instruction"].unique()))