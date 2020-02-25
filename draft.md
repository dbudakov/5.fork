ps ax
/PROC/[PID_number]/

advanced  
/PROC/DISKSTATS - Статистика ввода и вывода на блочные устройства  
/PROC/LOADAVG - load average  
/PROC/UPTIME

interest  
/PROC/KCORE - слепок памяти  
PROC/SYSRQ-TRIGGER - общение с ядром

#### рабочие наброски   
```
ll /proc/[$PID]/exe|awk '{print $11}' - выведет бинарник для $PID  
grep State /proc/[$PID]/status|awk '{print $2" "$3}'   # выведет состояние процесса
```
