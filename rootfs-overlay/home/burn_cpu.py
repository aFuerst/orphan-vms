import multiprocessing as mp
import os
import argparse
import psutil

def burn(proc, core, skip_affinity):
    if core is not None and not skip_affinity:
        p = psutil.Process()
        p.cpu_affinity([core])
    x = proc
    while True:
        x *= 2
        x &= 0xbadcafe

parser = argparse.ArgumentParser()
parser.add_argument('-p', "--procs", required=False, default=None, help="number of processes to start", type=int)
parser.add_argument('-c', "--cores", required=False, default=None, help="list of cores to run procs on", type=str)
parser.add_argument("--skip-affinity", required=False, help="Disable setting cpu affinity or not", action='store_true')
args = parser.parse_args()

cores = None
if args.cores is not None:
    cores = []
    for part in args.cores.split(','):
        if len(part) == 1 and str.isdigit(part):
            cores.append(int(part))
        elif '-' in part:
            first,last = part.split('-')
            for i in range(int(first), int(last)+1):
                cores.append(i)
        else:
            raise Exception(f"Unknown value '{part}'")

if cores is not None:
    procs = args.procs or os.cpu_count()
    if len(cores) != procs:
        raise Exception("num CPU cores not matching procs")
    with mp.Pool(processes=procs) as p:
        p.starmap(burn, [(i, cores[i], args.skip_affinity) for i in range(procs)])

with mp.Pool(processes=procs) as p:
    p.starmap(burn, [(i, None, args.skip_affinity) for i in range(procs)])
