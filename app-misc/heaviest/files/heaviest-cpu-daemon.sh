#!/bin/bash

# Directory to store log files
LOG_DIR="/tmp/top_procs"
# How many history files to keep (e.g. 10 or 30)
MAX_FILES=30 # Keep 30 files, so top_procs_01 to top_procs_30

# Make sure the log directory exists
mkdir -p "$LOG_DIR"

# Clear it only at the start
rm -f "$LOG_DIR"/top_procs_* &>/dev/null

while true; do
    # 1. Rotate files: Shift all existing files up by one number
    # This loop starts from MAX_FILES down to 1.
    # It ensures top_procs_30 (if MAX_FILES=30) is removed/overwritten
    # by top_procs_29, and top_procs_02 gets top_procs_01's content.
    for (( n=MAX_FILES; n>=1; n-- )); do
        old_file="$LOG_DIR/top_procs_$(printf "%02d" $n)"
        new_file="$LOG_DIR/top_procs_$(printf "%02d" $((n+1)))" # This will be MAX_FILES+1 for n=MAX_FILES

        # If we are at the MAX_FILES position, just delete the file.
        # Otherwise, move the file to the next number.
        if [ "$n" -eq "$MAX_FILES" ]; then
            rm -f "$old_file"
        else
            # Move the previous file to the current number's position
            if [ -f "$old_file" ]; then
                mv "$old_file" "$new_file"
            fi
        fi
    done

    # 2. Write new top processes to top_procs_01
    top -bn1 -c -o +%CPU -w 512 | head -n $((MAX_FILES + 8)) | tail -n +8 | awk '{if ($9 > 0.0) print}' | grep -v -e "heaviest-cpu-daemon" -e "top -bn1 -c -o +%CPU -w 512" > "$LOG_DIR/top_procs_01"

    # 3. Wait before repeating
    sleep 2
done
