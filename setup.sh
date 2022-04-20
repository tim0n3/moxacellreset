#!/bin/bash

function _main() {
	function _cronBak() {
	# move existing crontab file and replace with the one in this repo
	FILE=/var/spool/cron/crontabs/root
	if test -f "$FILE"; then
		mv /var/spool/cron/crontabs/root /root-crontab.bak
		cp /root/moxacellreset/scripts/root /var/spool/cron/crontabs/
		echo backing up root crontab
		exit 0
	else
		echo "$FILE doesn't exist."
		cp /root/moxacellreset/scripts/root /var/spool/cron/crontabs/
	fi
	}
	_cronBak;

	function _logs() {
		# create log files
		touch /home/moxa/app/inetmonit-success-events.log
		touch /home/moxa/app/inetmonit-fail-events.log
	}
	_logs;

	function _filePerm() {
		# assign file permissions and ownership
		chmod +x /root/moxacellreset/scripts/inetmonit.sh;
		chmod +rw /home/moxa/app/inetmonit-fail-events.log;
		chmod +rw /home/moxa/app/inetmonit-success-events.log;
		chmod 600 /var/spool/cron/crontabs/root;
		chown root:root /var/spool/cron/crontabs/root;
		chown moxa:moxa -R /home/moxa/app/;
		bash /root/moxacellreset/scripts/inetmonit;
		cat /home/moxa/app/;
	}
	_filePerm;
}
_main;