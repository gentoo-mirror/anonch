#!/usr/bin/env python3
import os
import glob
import sys
from collections import defaultdict

# Add a debug flag that can be enabled via command line argument
DEBUG = "--debug" in sys.argv

WEIGHT_MULTIPLIER = None
if len(sys.argv) > 1:
    WEIGHT_MULTIPLIER = float(sys.argv[1])

# Get files directly from Python - more efficient
files = sorted(glob.glob('/tmp/top_procs/top_procs_*'))

# Initialize data structures
cpu_sum = defaultdict(float)
cpu_wt = defaultdict(float)

lfs = len(files)
# Process all files in one pass
for idx, file_path in enumerate(files):
    if WEIGHT_MULTIPLIER:
        weight = 1 + (lfs-idx) / WEIGHT_MULTIPLIER
    else:
        weight = 1 + (lfs-idx) / len(files) / 1.5
    if DEBUG:
        print(f'Processing {file_path} with weight {weight}')

    try:
        with open(file_path, 'r') as f:
            for line in f:
                parts = line.split()
                if len(parts) >= 12:
                    try:
                        cpu = float(parts[8])  # $9 in awk is index 8 in Python
                        proc = parts[11]       # $12 in awk is index 11 in Python

                        # Accumulate directly in Python - no subprocess calls
                        cpu_sum[proc] += cpu * weight
                        cpu_wt[proc] += weight

                        if DEBUG:
                            print(f'  Line: CPU={cpu}, Proc={proc}')
                            print(f'    Updated: cpu_sum[{proc}]={cpu_sum[proc]} cpu_wt[{proc}]={cpu_wt[proc]}')
                    except (ValueError, IndexError):
                        continue
    except Exception as e:
        if DEBUG:
            print(f'Error processing file {file_path}: {e}')

# Calculate averages and find maximum in the same process
if DEBUG:
    print('Calculating weighted averages:')

max_proc = ''
max_val = 0

for proc, sum_val in cpu_sum.items():
    wt = cpu_wt[proc]
    if wt > 0:
        avg = sum_val / wt
    else:
        avg = 0

    if DEBUG:
        print(f'  Proc={proc} : Weighted Sum={sum_val}, Total Weight={wt}, Weighted Avg={avg}')

    if avg > max_val:
        max_val = avg
        max_proc = proc

# Print final result
if "--help" in sys.argv:
    print("Usage: harvest 2.2 [--debug] [--help]. Where 2.2 is weight 99 - means no emphasize recent measurements.")

elif DEBUG:
    print('===========================================')
    print(f'Heaviest recent CPU process: {max_proc}')
    print(f'Weighted average CPU usage: {max_val:.2f}%')
    print('===========================================')
else:
    # Remove any slashes from the name if it is kernel thread
    if max_proc.startswith('['):
        max_proc = max_proc.replace('/', '')
    # In non-debug mode, just output the name of the heaviest process
    program_name = os.path.basename(max_proc)
    if program_name != max_proc:
        max_proc = program_name
    print(max_proc, f'{max_val:.2f}%')
