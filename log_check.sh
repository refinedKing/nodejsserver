#/bin/bash 
#Program    log_check.sh
#Author     bingwang
#This script reads the service log config file: $host_services in /nishome/prodpe001/wu01/conf
#This config file only includes all the logs that are produced by the services in each servers. 
#You can configure this file to include or remove config item. One crontab is set up in each server (from prod0006-prod0018) to run this script every 20 mins to 
#get the latest status on these logs: i.e. last update time, size.
#set -x 

#variables are set here
conf_dir=/nishome/prodpe001/wu01/conf
log_dir=/nishome/prodpe001/wu01/logs
date2=`date +%Y-%m-%d`
host=`uname -n | cut -d"." -f 1`
# error list
errorlist='RuntimeException|MySQLSyntaxErrorException|InactivityIOException|Disconnected|EOFException|" Failed"|IllegalStateException|ibatis.exceptions.PersistenceException|SolrException|DEADLOCK|NoRouteToHostException|IOException'

echo "$errorlist"
#date1=`date | cut -d " " -f 3`
# 取得目前时间的元年的计时
date=`date "+%Y-%m-%d %H:%M:%S"`
datesec=`date -d "$date" +%s`

# main function starts from here
for service in `cat $conf_dir/"$host"_services`
do
  server=`echo $service | awk -F":" '{print $1}'`
  app=`echo $service | awk -F":" '{print $2}'`
  module=`echo $service | awk -F":" '{print $3}'`
  log=`echo $service | awk -F":" '{print $4}'`
  # 取得上次文件修改的元年计时
  logupdate=`stat $log | grep -i Modify | awk -F. '{print $1}' | awk '{print $2" "$3}'`
  logupdatesec=`date -d "$logupdate" +%s`
  result=$(($datesec-$logupdatesec))
  # 对比两者相差86400则为一天未更新
  if [ $result -gt 86400 ]; then
     n=`grep $log $conf_dir/ignore_log | wc -l `
	 if [ $n = 0 ]; then
	 echo "Log is found not updated in 1 day in $server $log" >> $log_dir/alert.log 
	 fi
  fi
  size=`ls -ltr $log| cut -d" " -f 5`
  if [ $size -gt 1000000000 ]; then
    echo "BIG LOG FILE FOUND!!! please clear the big log file $log in $server" >> $log_dir/alert.log
  fi
  
  [ -e $conf_dir/"$host"_"$module"_lines ] || echo 0 > $conf_dir/"$host"_"$module"_lines

  # 记录当前行数
  line=`cat $conf_dir/"$host"_"$module"_lines`
  # 目前行
  log_lines=`cat $log | wc -l`
  # 所有行
  if [ $line -gt $log_lines ]; then
    echo 0 > $conf_dir/"$host"_"$module"_lines
  fi

  if [ $line -eq $log_lines ]; then
    return 0
  fi
  result1=$(($log_lines-$line))

  count1=`tail -n $result1 $log | egrep -n "$errorlist" | wc -l`
  if [ $count1 != 0 ];then
    # 只记录错误的服务器信息行数信息,不在记录详细信息
    line_nums=`tail -n $result1 $log | egrep -n "$errorlist"| cut -d":" -f 1`
    line_num=`tail -n $result1 $log | egrep -n "$errorlist"| cut -d":" -f 1 | sort -rn | head -1`
    echo "Error is found in $log in $server on ($line_nums) lines" >> $log_dir/alert.log
    echo $line_num > $conf_dir/"$host"_"$module"_lines
  else
    echo $log_lines > $conf_dir/"$host"_"$module"_lines
  fi
done

for service in `cat $conf_dir/"$host"_services`
do
server=`echo $service | awk -F":" '{print $1}'`
app=`echo $service | awk -F":" '{print $2}'`
module=`echo $service | awk -F":" '{print $3}'`
log=`echo $service | awk -F":" '{print $4}'`

if [ $server == 'alihzprod0017' ] || [ $server == 'alihzprod0018' ]; then
  lines=`cat $conf_dir/"$host"_lines` # 目前行
  log_lines=`cat $log | wc -l`  # 所有行

  if [ $lines -gt $log_lines ]; then
    echo 0 > $conf_dir/"$host"_lines
  fi

  if [ $lines -eq $log_lines ]; then
    return 0
  fi

  result=$(($log_lines-$lines))
  declare -A arr
  for i in `tail -n $result debug.log | grep -n "\[ERROR\]" | awk '{++linearr[$1"&"$4]}; END {for(key in linearr) print key}' | sort -n`; do
    key=`echo $i | cut -d"&" -f 2`
    value=`echo $i | cut -d":" -f 1`
    arr[$key]=$value
  done
  if [ ${#arr[*]} -gt 0 ];then
    # 输出最后一行的错误信息
    echo "Error is found in $log in $server on (${arr[*]}) lines" >> $log_dir/alert.log
    # 记录最后一行错误信息
    for i in ${arr[*]};do
      echo $i >> /tmp/temp.txt
    done
    max=`cat /tmp/temp.txt | sort -rn | head -1`
    echo $max > $conf_dir/"$host"_lines
    >/tmp/temp.txt
  fi
fi
done

#临时方案
cat $log_dir/alert.log | sort -u > $log_dir/alert.log
