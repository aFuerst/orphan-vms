import multiprocessing as mp
import os
import argparse

def burn(i):
    x = i
    while True:
        x *= 2
        x &= 0xbadcafe

parser = argparse.ArgumentParser()
parser.add_argument('-p', "--procs", required=False, default=None, help="number of processes to start", type=int)
args = parser.parse_args()

procs = args.procs or os.cpu_count()
with mp.Pool(processes=procs) as p:
    p.map(burn, [i for i in range(procs)])