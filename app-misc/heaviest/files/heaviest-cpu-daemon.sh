#!/bin/bash

# Directory to store log files
LOG_DIR="/tmp/top_procs"
# How many history files to keep (e.g. 10 or 30)
MAX_FILES=30

# Make sure the log directory exists
mkdir -p "$LOG_DIR"

while true; do
    # 1. Remove any files with a number greater than or equal to MAX_FILES
    for file in "$LOG_DIR"/top_procs_*; do
        # Get the number at the end of the filename, e.g., top_procs_12 -> 12
        num=$(basename "$file" | awk -F_ '{print $3}')
        # If the file number is >= MAX_FILES, remove it
        if [ "$num" -ge "$MAX_FILES" ] 2>/dev/null; then
            rm -f "$file"
        fi
    done

    # 2. Shift files: each file moves up one number (e.g., 09 -> 10, 01 -> 02)
    # Do this backwards so we don't overwrite files
    for (( n=MAX_FILES-1; n>=1; n-- )); do
        old_file="$LOG_DIR/top_procs_$(printf "%02d" $n)"
        new_file="$LOG_DIR/top_procs_$(printf "%02d" $((n+1)))"
        if [ -f "$old_file" ]; then
            mv "$old_file" "$new_file"
        fi
    done

    # 3. Write new top processes to top_procs_01
    # awk '{print $9}'
    top -b -n 1 -c -o %CPU -w 500 | grep -v "top -b" | awk '/^[ ]*[0-9]/ {found=1} found' | head -n 21 > "$LOG_DIR/top_procs_01"
    # ps -eo pid,user,pcpu,pmem,cmd --sort=-pcpu | head -n 21 > "$LOG_DIR/top_procs_01"

    # 4. Wait a second before repeating
    sleep 1
done
