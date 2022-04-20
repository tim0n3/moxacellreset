#!/bin/bash

function _main() {
	# move script
	function _script() {
	# move existing crontab file and replace with the one in this repo
	FILE=/usr/sbin/cellular-keepalive.sh
	if test -f "$FILE"; then
		mv /usr/sbin/cellular-keepalive.sh /root/cellular-keepalive.bak;
		cp /root/moxacellreset/advanced/cellular-keepalive.sh /usr/sbin/;
		echo moving keepalive script to /usr/sbin/;
	else
		echo "$FILE doesn't exist."
		cp /root/moxacellreset/advanced/cellular-keepalive.sh /usr/sbin/;
	fi
	}
	_cronBak;
}