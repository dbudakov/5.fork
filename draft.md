##### script
```
head -1 -q 2>/dev/null $(find /proc/*/sched 2>/dev/null)|sed -e 's/\ (/\ /g'|sed -e 's/,/\ /g'|awk '{print $2}'>PID
for i in $(cat PID); do array[$i]=$(head -1 -q /proc/$i/sched 2>/dev/null|sed -e 's/\ (/\ /g'|sed -e 's/,/\ /g'|awk '{print $2}'); NAME[$i]=$(head -1 -q /proc/$i/sched 2>/dev/null|sed -e 's/\ (/\ /g'|sed -e 's/,/\ /g'|awk '{print $1}'); STATE[$i]=$(grep State /proc/$i/status 2>/dev/null |awk '{print $2}');done
for i in ${array[*]};do echo -e "${array[$i]}\t${STATE[$i]}\t${NAME[$i]}\t${TIME[$i]}";done|column -t

```

ps ax
/PROC/[PID_number]/
```
cmdline - содержит команду с помощью которой был запущен процесс, а также переданные ей параметры
cwd - символическая ссылка на текущую рабочую директорию процесса
exe - ссылка на исполняемый файл
root - ссылка на папку суперпользователя
environ - переменные окружения, доступные для процесса
fd - содержит файловые дескрипторы, файлы и устройства, которые использует процесс
maps, statm, и mem - информация о памяти процесса
stat, status - состояние процесса
```
advanced  
/PROC/DISKSTATS #cтатистика ввода и вывода на блочные устройства  
/PROC/LOADAVG   #load average  
/PROC/UPTIME
/proc/PID/task  #каталог, содержащий жесткие ссылки на любые задачи, которые были начаты этим процессом.

interest  
/PROC/KCORE - слепок памяти  
PROC/SYSRQ-TRIGGER - общение с ядром

#### рабочие наброски   
```
PID and NAME
head -1 -q 2>/dev/null $(find /proc/*/sched 2>/dev/null)|sed -e 's/\ (/\ /g'|sed -e 's/,/\ /g'
grep State /proc/*/status|awk '{print $2" "$3}'   # выведет состояние процесса
stat /proc/*|awk '/Modify/{print $2" "$3}'|cut -d: -f 1-2 # выведет время создания PID'a
```
```
#запись в массив имя по ПИД
#for i in ${array[*]};do NAME[$i]=$(head -1 -q /proc/$i/sched 2>/dev/null)|sed -e 's/\ (/\ /g'|sed -e 's/,/\ /g'|awk '{print $1}');done

#запись в массив состояние по ПИД
#for i in ${array[*]};do STATE[$i]=$(grep State /proc/$i/status 2>/dev/null |awk '{print $2" "$3}');done

#запись в массив времени по ПИД
#for i in ${array[*]};do TIME[$i]=$(stat /proc/$i 2>/dev/null|awk '/Modify/{print $2" "$3}'|cut -d: -f 1-2 );done

вывод 
for i in ${array[*]};do echo -e "${array[$i]}\t${STATE[$i]}\t${NAME[$i]}\t${TIME[$i]}";done|column -t




#ll /proc/[$PID]/exe|awk '{print $11}'                  # выведет бинарник для $PID  
#head /proc/[$PID]/shed|awk '{print $1}'                # выведет имя программы для пустых 'exe'
```


