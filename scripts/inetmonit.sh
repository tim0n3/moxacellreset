#!/bin/bash

function _testComms() {
	# Set target host IP or hostname
    TARGET_HOST='8.8.8.8'

    # Set count
    count=$(ping -c 3 $TARGET_HOST | grep icmp* | wc -l)

    # If no network. Log event in log file in the specified location then run reset commands
    if [ $count -eq 0 ]; then
        echo "$(date)" "Target host" $TARGET_HOST "unreachable, Rebooting!" >>/home/moxa/app/inetmonit-fail-events.log;
        cell_mgmt power_cycle;
        sleep 5;
        cell_mgmt restart;
    else
        echo "$(date) ===-> OK! " >>/home/moxa/app/inetmonit-success-events.log;
        exit 0
    fi
}
_testComms;