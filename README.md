## Домашнее задание  
Работаем с процессами  
Цель: В результате выполнения ДЗ студент запустит скрипт, запускающий два процесса.  
Задания на выбор  
1) написать свою реализацию ps ax используя анализ /proc  
Результат ДЗ - рабочий скрипт который можно запустить  
2) написать свою реализацию lsof  
Результат ДЗ - рабочий скрипт который можно запустить  
3) дописать обработчики сигналов в прилагаемом скрипте, оттестировать, приложить сам скрипт, инструкции по использованию  
Результат ДЗ - рабочий скрипт который можно запустить + инструкция по использованию и лог консоли  
4) реализовать 2 конкурирующих процесса по IO. пробовать запустить с разными ionice  
Результат ДЗ - скрипт запускающий 2 процесса с разными ionice, замеряющий время выполнения и лог консоли  
5) реализовать 2 конкурирующих процесса по CPU. пробовать запустить с разными nice  
Результат ДЗ - скрипт запускающий 2 процесса с разными nice и замеряющий время выполнения и лог консоли  
Критерии оценки: 5 баллов - принято - любой скрипт  
+1 балл - больше одного скрипта  
+2 балла все скрипты  

## Решение  
### script 
```shell
#!/bin/bash
#custom `ps ax``
for i in $(ls /proc|grep ^[0-9]);do NAME[$i]=$(head -1 -q /proc/$i/sched 2>/dev/null|sed -e 's/\ (/\ /g'|sed -e 's/,/\ /g'|awk '{print $1}'); STATE[$i]=$(grep State /proc/$i/status 2>/dev/null |awk '{print $2}');TIME[$i]=$(stat /proc/$i 2>/dev/null|awk '/Modify/{print $2" "$3}'|cut -d: -f 1-2);done
for i in $(ls /proc|grep ^[0-9]|sort -n);do echo -e "$i\t${STATE[$i]}\t${NAME[$i]}\t${TIME[$i]}";done|awk 'BEGIN {print "PID STATE NAME UPTIME"}/[00-23]\:[00-59]/{print}'|column -t
```
в первой строке собираем информацию о каждом процессе в массивы:
```shell
for i in $(ls /proc|grep ^[0-9]);
do 
NAME[$i]=$(head -1 -q /proc/$i/sched 2>/dev/null|sed -e 's/\ (/\ /g'|sed -e 's/,/\ /g'|awk '{print $1}');
STATE[$i]=$(grep State /proc/$i/status 2>/dev/null |awk '{print $2}');
TIME[$i]=$(stat /proc/$i 2>/dev/null|awk '/Modify/{print $2" "$3}'|cut -d: -f 1-2);
done

#description:
for i in $(ls /proc|grep ^[0-9])  # запускаем цикл по for для каждой строки из /proc
                                  # содержащей только время,что по сути является PID'ом процесса
do                    # символизирует начало операций для $i
NAME[$i]=$(           # для каждого $i записываем имя в массив NAME, "$(" символизирует об операции внутри
head -1 -q /proc/$i/sched 2>/dev/null|  # читаем первую строку по указаному пути без вывода наименования файла
sed -e 's/\ (/\ /g'|  # заменяем все знаки " (" на пробел 
sed -e 's/,/\ /g'|    # заменяем все знаки "," на пробел
awk '{print $1}' );   # выбираем второе поле, ")" закрывает операцию, ";" переход на следующую команду

STATE[$i]=$(          # задаем масив STATE в который запишем статус процесса
grep State /proc/$i/status 2>/dev/null|  # выборка строки с сотоянием процесса из файла
awk '{print $2}');    # выборка по второму полю, переход к следующей операции

TIME[$i]=$(           # задаем массив TIME для времени старта процесса
stat /proc/$i 2>/dev/null|  # выводим метаинформацию о каталогу PID'a 
awk '/Modify/{print $2" "$3}'|  #выбираем 2 и 3 поля из строки содержащей "Modify"
cut -d: -f 1-2);      # делим строку знаком ":", и выводим нужные значения
done                  # cимволизирует об окончании операции для $i и $i принимает следующее значение
```
вторая строка вывод:
```shell
for i in $(ls /proc|grep ^[0-9]|sort -n);
do 
echo -e "$i\t${STATE[$i]}\t${NAME[$i]}\t${TIME[$i]}";
done|
awk 'BEGIN {print "PID STATE NAME UPTIME"}/[00-23]\:[00-59]/{print}'|
column -t;

for i in $(ls /proc|grep ^[0-9]|sort -n)   # задаем значения $i равные файлам начинающимся с цифры 
                                           # в каталоге /proc 
echo -e "$i\t${STATE[$i]}\t${NAME[$i]}\t${TIME[$i]}"  # выводим значения из массива для $i, 
awk 'BEGIN {print "PID STATE NAME UPTIME"}/[00-23]\:[00-59]/{print}' # ловим вывод, задаем шапку и
                                                                     # выбираем все строки 
                                                                     # в которых имеется время

column -t   # задает формат вывода в виде таблицы
```

```
########################################################################################################
########################################################################################################
########################################################################################################
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
```
