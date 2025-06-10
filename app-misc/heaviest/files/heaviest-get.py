#!/usr/bin/env python3
import os
import glob
import sys
import re
from collections import defaultdict

# Add a debug flag that can be enabled via command line argument
DEBUG = "--debug" in sys.argv

WEIGHT_MULTIPLIER: float = 1.5
if len(sys.argv) > 1:
    WEIGHT_MULTIPLIER = float(sys.argv[1])

# Get files directly from Python - more efficient
files = sorted(glob.glob('/tmp/top_procs/top_procs_*'))

# Initialize data structures
cpu_sum = defaultdict(float)
wt_sum = 0

lfs = len(files)
# Process all files in one pass
for idx, file_path in enumerate(files): # 0, 1
    # 20 - 0 = 20/20  / 1.5 = 0.6
    # 20 - 18 = 0.06
    weight = (1 + (lfs - idx)) / len(files) / WEIGHT_MULTIPLIER

    wt_sum += weight
    if DEBUG:
        print(f'Processing {file_path} with weight {weight}')

    try:
        if os.path.getsize(file_path) == 0:
            continue
        with open(file_path, 'r') as f:
            for line in f:
                # We use re.split for more robust splitting across multiple spaces.
                parts = re.split(r'\s+', line)

                if len(parts) >= 12:
                    try:
                        cpu = float(parts[8])  # %CPU
                        proc = parts[11]        # COMMAND is at index 4 (5th field)
                        proc_full = " ".join(parts[11:])

                        # if proc == "-bash":
                        # print(idx, file_path, cpu, cpu * weight, proc_full)

                        # Accumulate directly in Python - no subprocess calls
                        cpu_sum[proc] += cpu * weight

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
    avg = sum_val / wt_sum

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
