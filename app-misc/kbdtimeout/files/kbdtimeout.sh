#!/usr/bin/env bash

# --- Read configuration ---
# Timeout in seconds
TIMEOUT=$(cat /etc/kbdtimeout/default.conf | grep TIMEOUT | grep -o '[0-9]*') #300 # 5 min
# characters have been readed from keyboard device directly
CAT_LEN_READ=$(cat /etc/kbdtimeout/default.conf | grep CAT_LEN_READ | grep -o '[0-9]*') # 25
# Command to execute after timeout
COMMAND_TO_EXECUTE=$(cat /etc/kbdtimeout/default.conf | grep COMMAND_TO_EXECUTE | cut -d '=' -f 2)
DEBUG=$(cat /etc/kbdtimeout/default.conf | grep DEBUG | cut -d '=' -f 2)

# --- Detect device ---
# The specific event device for your keyboard
dev_number=$(cat /proc/bus/input/devices | grep 'Handlers=' | grep rfkill | grep kbd | grep leds | grep event | grep -o '[0-9]*')

KEYBOARD_DEVICE=
if [[ -n "$dev_number" ]]; then
    KEYBOARD_DEVICE="/dev/input/event${dev_number}"
else
    # - loop 25 times for 0.5 sec for every device
    break_flag=
    for j in $(seq 0 24); do
	test "$break_flag" && break
	for f in /dev/input/event* ; do
	    test "$DEBUG" && echo Checking device "$f"
            kread=$(timeout 0.5 cat $f | tr -d '\0' 2>/dev/null)
	    kread_num=$(echo "$kread" | wc -c) 2>/dev/null
	    test "$DEBUG" && echo kread_num=$kread_num
            if [[ "$kread_num" -ge 17 ]]; then
		test "$DEBUG" && echo Keyboard found: "$f"
		KEYBOARD_DEVICE=$f
		break_flag=1
		break
            fi
	done
    done

    if [[ -z "$KEYBOARD_DEVICE" ]]; then
	MESSAGE="kbdtimeout demon: Keyboard debice was not found."

	for tty in /dev/tty[1-9]* /dev/tty0 /dev/pts/*; do
	    if [ -c "$tty" ]; then
		echo "$MESSAGE" > "$tty"
	    fi
	done
	eval "$COMMAND_TO_EXECUTE"
        exit 1
    fi
fi

test "$DEBUG" && echo KEYBOARD_DEVICE=$KEYBOARD_DEVICE
# --- Listen for events ---
while true; do
    # Attempt to read from the device with a timeout and check the output size
    kread=$(timeout $TIMEOUT cat "$KEYBOARD_DEVICE" | tr -d '\0' 2>/dev/null)
    kread_num=$(echo "$kread" | wc -c) 2>/dev/null
    test "$DEBUG" && echo kread_num=$kread_num
    if [[ $kread_num -gt $CAT_LEN_READ ]]; then
        # - Was activity
        test "$DEBUG" && echo Was activity kread_num=$kread_num -gt CAT_LEN_READ=$CAT_LEN_READ
    else
        # - No keyboard activity
        test "$DEBUG" && echo No keyboard activity kread_num=$kread_num -gt CAT_LEN_READ=$CAT_LEN_READ
        eval "$COMMAND_TO_EXECUTE"
    fi

    sleep 1
done
