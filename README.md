### script custom `ps ax`
```shell
#!/bin/bash
head -1 -q 2>/dev/null $(find /proc/*/sched 2>/dev/null)|sed -e 's/\ (/\ /g'|sed -e 's/,/\ /g'|awk '{print $2}'>PID
for i in $(cat PID); do array[$i]=$(head -1 -q /proc/$i/sched 2>/dev/null|sed -e 's/\ (/\ /g'|sed -e 's/,/\ /g'|awk '{print $2}'); NAME[$i]=$(head -1 -q /proc/$i/sched 2>/dev/null|sed -e 's/\ (/\ /g'|sed -e 's/,/\ /g'|awk '{print $1}'); STATE[$i]=$(grep State /proc/$i/status 2>/dev/null |awk '{print $2}');TIME[$i]=$(stat /proc/$i 2>/dev/null|awk '/Modify/{print $2" "$3}'|cut -d: -f 1-2);done
for i in ${array[*]}; do echo -e "${array[$i]}\t${STATE[$i]}\t${NAME[$i]}\t${TIME[$i]}";done|awk 'BEGIN {print "PID STATE NAME UPTIME"}{print}'|column -t
```
