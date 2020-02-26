### script 
```shell
#!/bin/bash
#custom `ps ax`
for i in $(ls /proc|grep ^[0-9]);do NAME[$i]=$(head -1 -q /proc/$i/sched 2>/dev/null|sed -e 's/\ (/\ /g'|sed -e 's/,/\ /g'|awk '{print $1}'); STATE[$i]=$(grep State /proc/$i/status 2>/dev/null |awk '{print $2}');TIME[$i]=$(stat /proc/$i 2>/dev/null|awk '/Modify/{print $2" "$3}'|cut -d: -f 1-2);done
for i in $(ls /proc|grep ^[0-9]|sort -n);do echo -e "$i\t${STATE[$i]}\t${NAME[$i]}\t${TIME[$i]}";done|awk 'BEGIN {print "PID STATE NAME UPTIME"}/[00-23]\:[00-59]/{print}'|column -t
```
три строчки, в первой собираем номера пидов
```shell
for i in $(ls /proc|grep ^[0-9])  # запускаем цикл по for для каждой строки из /proc содержащей только время,что по сути является PID'ом процесса
do                    # символизирует начало операций для $i
NAME[$i]=$(           # для каждого $i записываем имя в массив NAME, "$(" символизирует об операции внутри
head -1 -q /proc/$i/sched 2>/dev/null|  # читаем первую строки по указаному пути без вывода наименования файла
sed -e 's/\ (/\ /g'|  # заменяем все знаки " (" на пробел 
sed -e 's/,/\ /g'|    # заменяем все знаки "," на пробел
awk '{print $1}' );   # выбираем второе поле, ")" закрывает операцию, ";" переход на следующую команду

STATE[$i]=$(          # задаем масив STATE в который запишем статус процесса
grep State /proc/$i/status 2>/dev/null|  # выборка строки с сотоянием процесса из файла статуса процесса
awk '{print $2}');    # выборка по второму полю, переход к следующей операции

TIME[$i]=$(           # задаем массив TIME для времени старта процесса
stat /proc/$i 2>/dev/null|  # выводим метаинформацию о каталогу PID'a 
awk '/Modify/{print $2" "$3}'|  #выбираем 2 и 3 поля из строки содержащей "Modify"
cut -d: -f 1-2);      # делим строку знаком ":", и выводим нужные значения
done                  # cимволизирует об окончании операции для $i и $i принимает следующее значение
