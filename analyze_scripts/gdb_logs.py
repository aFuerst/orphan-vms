import argparse
from collections import defaultdict
import os

parser = argparse.ArgumentParser()
parser.add_argument('-f', "--folder", required=True, help="gdb log outputs folder")
args = parser.parse_args()

def sanitize(line):
    parts = list(filter(lambda x: len(x) > 0, line.split(" ")))
    keep = []
    keep.append(parts.pop(0))
    addr = parts.pop(0)
    keep.append(addr)
    if addr.startswith("0x"):
        if addr == "0x0000000000000000":
            return None
        keep.append(parts.pop(0))
        keep.append(parts.pop(0))
    keep.append("at")
    keep.append(parts.pop())

    return " ".join(keep)

def sanitize_file(file):
    data = defaultdict(int)
    with open(os.path.join(args.folder, file), "r") as f:
            line = f.readline()
            while line != "":
                if line.startswith("#0"):
                    trace = [sanitize(line)]
                    while True:
                        line = f.readline()
                        if line.startswith("#"):
                            safe = sanitize(line)
                            if safe is not None:
                                trace.append(safe)
                        else:
                            break
                    data["".join(trace)] += 1
                line = f.readline()

    tp = file.split('.')[0]
    with open(os.path.join(args.folder, f"{tp}.san"), 'w') as f:
        for k, v in sorted(data.items(), key=lambda x: x[1], reverse=True):
            f.write(f"{v}\n")
            f.write(f"{k}\n")

for file in os.listdir(args.folder):
    if ".log" in file:
        sanitize_file(file)
        