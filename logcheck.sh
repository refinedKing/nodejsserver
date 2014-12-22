# variables are set here
conf_dir=/nishome/prodpe001/wu01/conf
log_dir=/nishome/prodpe001/wu01/logs
logstash_dir=/nishome/prodpe001/wu01/logstash
host=`uname -n | cut -d"." -f 1`
errorlist='NumberFormatException|IndexOutOfBoundsException|RuntimeException|MySQLSyntaxErrorException|InactivityIOException|Disconnected|EOFException|" Failed"|IllegalStateException|ibatis.exceptions.PersistenceException|SolrException|DEADLOCK|NoRouteToHostException|IOException|DataIntegrityViolationException|HttpHostConnectException'
date=`date "+%Y-%m-%d %H:%M:%S"`
datesec=`date -d "$date" +%s`

# main function starts from here
for service in `cat $conf_dir/"$host"_services`
do
  server=`echo $service | awk -F":" '{print $1}'`
  app=`echo $service | awk -F":" '{print $2}'`
  module=`echo $service | awk -F":" '{print $3}'`
  log=`echo $service | awk -F":" '{print $4}'`

  # 日志是否一天未更新
  logupdate=`stat $log | grep -i Modify | awk -F. '{print $1}' | awk '{print $2" "$3}'`
  logupdatesec=`date -d "$logupdate" +%s`
  result=$(($datesec-$logupdatesec))
  if [ $result -gt 86400 ]; then
     n=`grep $log $conf_dir/ignore_log | wc -l `
     if [ $n = 0 ]; then
  echo "Log is found not updated in 1 day in $server $log" >> $log_dir/alert.log 
     fi
  fi

  # 日志是否超过1G没有滚动
  size=`ls -ltr $log| cut -d" " -f 5`
  if [ $size -gt 1000000000 ]; then
    echo "BIG LOG FILE FOUND!!! please clear the big log file $log in $server" >> $log_dir/alert.log
  fi
  
  # 初始化日志检测行信息(仅执行一次)
  [ -e $conf_dir/"$host"_"$module"_lines ] || echo 0 > $conf_dir/"$host"_"$module"_lines

  # 按规则检测日志
  line=`cat $conf_dir/"$host"_"$module"_lines`
  log_lines=`cat $log | wc -l`
  if [ ! $line ]; then
    echo 0 > $conf_dir/"$host"_"$module"_lines
    line=0
  fi
  if [ $line -gt $log_lines ]; then
    echo 0 > $conf_dir/"$host"_"$module"_lines
    line=0
  fi
  if [ $line -eq $log_lines ]; then
    continue
  fi
  result=$(($log_lines-$line))

  # 如果prod17,18则是if
  if [ $server == 'alihzprod0017' ] || [ $server == 'alihzprod0018' ]; then
    declare -A arr
    for i in `tail -n $result $log | grep -n "\[ERROR\]" | awk '{++linearr[$1+"'$line'""&"$4$5]}; END {for(key in linearr) print key}' | sort -n`; do
      key=`echo $i | cut -d"&" -f 2`
      value=`echo $i | cut -d"&" -f 1`
      arr[$key]=$value
    done
    if [ ${#arr[*]} -gt 0 ];then
      echo "Error is found in $log in $server on (${arr[*]}) lines -- $date" >> $log_dir/alert.log
      #添加错误的信息，供logstash使用
      count1=`tail -n $result $log | egrep "$errorlist" | wc -l`
      if [ $count1 -gt 0 ]; then
        echo -n "[ERROR] Error is found in [$module] $log in $server " >> $logstash_dir/"$server"_"$module".log
        tail -n $result $log | egrep -A 20 -B 10 "$errorlist" >> $logstash_dir/"$server"_"$module".log
      fi
      for i in ${arr[*]};do
        echo $i >> /tmp/temp.txt
      done
      max=`cat /tmp/temp.txt | sort -rn | head -1`
      echo $max > $conf_dir/"$host"_"$module"_lines
      >/tmp/temp.txt
    else
      echo $log_lines > $conf_dir/"$host"_"$module"_lines
    fi
  else
    count=`tail -n $result $log | egrep -n "$errorlist" | wc -l`
    if [ $count -gt 0 ];then
      line_nums=`tail -n $result $log | egrep -n "$errorlist"| cut -d":" -f 1 | awk '{print $1+"'$line'"}' | sort -rn | head -20`
      line_num=`tail -n $result $log | egrep -n "$errorlist"| cut -d":" -f 1 | sort -rn | head -1 | awk '{print $1+"'$line'"}'`
      echo "Error is found in $log in $server on ($line_nums) lines -- $date" >> $log_dir/alert.log
      echo $line_num > $conf_dir/"$host"_"$module"_lines
      #添加错误的信息，供logstash使用
        echo -n "[ERROR] Error is found in [$module] $log in $server " >> $logstash_dir/"$server"_"$module".log
        tail -n $result $log | egrep -A 20 -B 10 "$errorlist" >> $logstash_dir/"$server"_"$module".log
    else
      echo $log_lines > $conf_dir/"$host"_"$module"_lines
    fi
  fi
done

#临时方案
#cat $log_dir/alert.log | sort -u > $log_dir/alert.log
