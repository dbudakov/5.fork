#!/bin/bash
#custom `ps ax`

HZ=$(getconf CLK_TCK)
#HZ=$(grep 'CONFIG_HZ=' /boot/config-$(uname -r)|awk -F= '{print $2}')

Sort() {
        ls /proc|
        grep ^[0-9]|
        sort -n
}

Name() {
        head -1 -q /proc/$i/sched 2>/dev/null|
        sed -e 's/\ (/\ /g'|
        sed -e 's/,/\ /g'|
        awk '{print $1}'
}

state() {
        grep State /proc/$i/status 2>/dev/null |
        awk '{print $2}'
}

Time() {
        sim() {
        if [ $utime -eq 0 ]
        then
                echo "0:0"
        else
                a=$(echo "scale=10;($utime+$stime+$cutime+$cstime)/$HZ/60"|bc -l|sed 's/^\./0./')
                d=$(echo $a|cut -d. -f 1)
                f=$(echo "$(echo "($a-$d)*60"|bc|sed 's/^\./0./'|cut -c 1-2)")
                if [[ "$f" == *[.]  ]]
                        then f=$(echo $f|sed 's/\./0/'|rev)
                        fi

                        echo "$d:$f"
        fi
        }

        utime=$(awk '/[0-9]/{print $14}' /proc/$i/stat 2>/dev/null)
        stime=$(awk '/[0-9]/{print $15}' /proc/$i/stat 2>/dev/null)
        cutime=$(awk '/[0-9]/{print $16}' /proc/$i/stat 2>/dev/null)
        cstime=$(awk '/[0-9]/{print $17}' /proc/$i/stat 2>/dev/null)
        if [ -z $utime ] 2>/dev/null
        then echo "FALSE"               
        else
                if [ $uptime -eq "0" ] 2>/dev/null
                then echo "0:0"
                else
                k=$(sim)
                echo $k
                fi
        fi
}

Main() {

        for i in $(Sort)
        do
        NAME[i]=$(Name)
        STATE[i]=$(state)
        TIME[i]=$(Time)
        done
}

Head() {
        awk 'BEGIN {print "PID STATE NAME UPTIME"}{print}'|
        column -t
        }

Show() {
        for i in $(Sort)
        do
                echo -e "$i\t${STATE[$i]}\t${NAME[$i]}\t${TIME[$i]}"|
                awk '/[A-Z]/{print $0}'
        done|Head
}

Main
Show
