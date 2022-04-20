#!/bin/bash

PING_TARGET="8.8.8.8"
PING_COUNT="3"
LOG_FILE="/dev/shm/record"
QMI_NODE="/dev/cdc-wdm0"
#QMI_IF="wwan0"
#PIN_CODE="0000"

# to keep cellular connection alive.
keep_alive () {
        local err_cnt=0
        ping $PING_TARGET -c $PING_COUNT
        while [ x"$?" != x"0" ]; 
        do
                err_cnt=$(($err_cnt+1))
                err_chk $err_cnt
                cell_mgmt restart
                sleep 10
                # ifconfig ${QMI_IF} mtu 1500
                date=$(date +"%Y/%m/%d %H:%M:%S")
                echo "$date Cannot ping $PING_TARGET, restart the connection..." > $LOG_FILE
                ping $PING_TARGET -c $PING_COUNT
        done
}

err_chk () {
        if [ "$1" -gt 3 ]; then
                cell_mgmt power_cycle
                echo "$date Cannot get signal, reset module..." > $LOG_FILE
                sleep 30
        fi
}

# fetch cellular info. via utility of libqmi
log_data () {
    local status=""
    local dbm=""
        local err_cnt=0
    # cellular disconnected
    while [ x"$status" == x"disconnected" ] || [ x"$status" != x"connected" ]; do
                err_cnt=$(($err_cnt+1))
                err_chk $err_cnt
                if [ x"$status" == x"disconnected" ]; then
                        cell_mgmt restart
                        # ifconfig ${QMI_IF} mtu 1500
                        date=$(date +"%Y/%m/%d %H:%M:%S")
                        echo "$date Cannot reach AP anymore, restart the connection..." > $LOG_FILE
                fi
                status=$(cell_mgmt status | head -n 1 | awk '{print $2}')
                sleep 0.5
    done
        err_cnt=0
    while [ x"$dbm" == x"" ] || [ x"$dbm" == x"dbm " ]; do
                err_cnt=$(($err_cnt+1))
                err_chk $err_cnt
                if [ x"$dbm" == x"dbm " ]; then
                        qmicli -p -d ${QMI_NODE} --nas-reset
                        date=$(date +"%Y/%m/%d %H:%M:%S")
                        echo "$date Cannot fetch signal, reset NAS function of module..." > $LOG_FILE
                fi
                dbm=$(cell_mgmt signal | awk '{print $1 " " $2}')
                sleep 0.5
    done
    date=$(date +"%Y/%m/%d %H:%M:%S")
    echo "$date $dbm $status" > $LOG_FILE
}

#enter pin code to unlock sim card
unlock_simcard () {
        qmicli -p -d $QMI_NODE --dms-uim-verify-pin="PIN,$PIN_CODE"
        echo "Unlock SIM card..."
        sleep 1
}

count=0

#unlock_simcard
while true; do
        # keep alive every 5 min.
        if [ x"$(($count%5))" == x"0" ]; then
                keep_alive
        fi
        # log data in every 10-min.
        if [ x"$(($count%10))" == x"0" ]; then
                log_data
                count=0
        fi
        count=$(($count+1))
        sleep 59
done