import multiprocessing as mp
import os

def burn(i):
    x = i
    while True:
        x *= 2
        x &= 0xbadcafe

procs = os.cpu_count()
with mp.Pool() as p:
    p.map(burn, [i for i in range(procs)])