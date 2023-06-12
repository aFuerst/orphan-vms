import argparse
from time import sleep

parser = argparse.ArgumentParser()
parser.add_argument('-m', "--memory", default=1024, help="memory in mb to allocate")
args = parser.parse_args()

memory = []

for i in range(args.memory):
    memory.append([0]*1024*1024)
    sleep(1)

while True:
    sleep(1)