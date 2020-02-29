#!/bin/bash

name() {
	head -1 -q /proc/$i/sched 2>/dev/null|
	sed -e 's/\ (/\ /g'|
	sed -e 's/,/\ /g'|
	awk '{print $1}'	
}

state() {
	grep State /proc/$i/status 2>/dev/null |
	awk '{print $2}')
}
####################################################
time() {
	stat /proc/$i 2>/dev/null|
	awk '/Modify/{print $2" "$3}'|
	cut -d: -f 1-2
}
#####################################################
srrt() {
	ls /proc|
	grep ^[0-9]|
	sort -n
}

main() {
	for i in $(srt)
	do
	NAME[i]=name; 
	STATE[i]=state
	TIME[i]=time
	done
}

head() {
	awk 'BEGIN {print "PID STATE NAME UPTIME"}/[00-23]\:[00-59]/{print}'|
	column -t
	}

show() {
	for i in $(srt)
	do
		echo -e "$i\t${STATE[$i]}\t${NAME[$i]}\t${TIME[$i]}"
	done|head
}

main
show
	
