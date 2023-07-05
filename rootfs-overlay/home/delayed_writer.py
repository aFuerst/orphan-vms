from time import sleep
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-t', "--time", required=False, default=30, help="time to sleep", type=int)
args = parser.parse_args()

sleep(args.time)

print("testing writing to console!")