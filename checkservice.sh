#########################################################################
# File Name: checkservice.sh
# Author: bingwang
# mail: bingwang@cekasp.com
# Version: 1.0 各模块基础启动功能完成  2014.7.10
# 		   1.1 添加自动启动功能(按需启动)  2014.7.14
#          1.2 添加停止各模块功能  2014.7.16
#          1.3 脚本逻辑重构  2014.7.17
#		   1.4 修复部分逻辑  2014.7.18
#########################################################################

#########################################################################
#----------------------------------------------
#--------------推荐模块命名目录----------------
#----------------------------------------------
#-----------基础模块安装目录配置---------------
javapath=/usr/lib/jvm/jre-1.7.0-openjdk.x86_64
tomcatpath=/data01/portal
activemqpath=/data01/activemq
gearmandpath=/data01/gearman
redispath=/data01/redis
#------------portal模块安装目录配置------------
portalpath=/data01/portal
#-----------frontend模块安装目录配置-----------
frontendpath=/data01/frontend
#------------jobman模块安装目录配置------------
jobmanagerpath=/data01/job-manager
jobmanager_resendpath=/data01/job-manager_resend
jobmanager_etlpath=/data01/job-manager-etl
#------------search模块安装目录配置------------
zookeeperpath=/data01/zookeeper
ltppath=/data01/ltp
solrpath=/data01/solr_pkg
dataprocesspath=/data01/dp
#--------datacollection模块安装目录配置--------
datacollectpath=/data01/dc/
dataproxy=/data01/frontend
#########################################################################

#!/bin/bash
[ -r /etc/rc.d/init.d/functions ] && . /etc/rc.d/init.d/functions
#[ -r `pwd`/conf ] && . `pwd`/conf

displays() {
	echo -ne "$1"
		success
	echo
}

displayf() {
	echo -ne "$1"
		failure
	echo
}

displayc() {
	echo "----------------------------------------------"
}

checkjava() {
	if [ "$1" == "stop" ]; then
		displayf java[不能停止]
	fi

	$javapath/bin/java -version &> /dev/null
	if [ $? -eq 0 ];then
		displays java[正常]
	else
		displayf java[异常]
	fi
}

checktomcat() {
	if [ "$1" == "portal" ] || [ "$2" == "portal" ];then
		$tomcatpath=$portalpath
	fi
	if [ "$2" == "frontend" ] || [ "$2" == "frontend" ]; then
		$tomcatpath=$frontendpath
	fi

	status=`ps -ef | grep tomcat | awk '{ if ($3 == 1) print $2 }' | wc -l`
	if [ -d $tomcatpath ];then
		if [ "$status" -eq 2 ];then
			if [ "$1" == "stop" ]; then
				status=`ps -ef | grep tomcat | awk '{ if ($3 == 1) print $2 }'`
				for i in $status; do
					kill -9 $i
				done
				if [ $? -eq 0 ];then
					displays tomcat[停止]
				else
					displayf tomcat[停止]
				fi
			else
				displays tomcat服务正在运行!
			fi
		else
			if [ "$1" == "stop" ]; then
				displays tomcat服务已经停止!
			else
				# TODO $2 双启动
				echo "正在尝试重启tomcat服务!"
				$tomcatpath/bin/startup.sh &> /dev/null
				if [ $? -eq 0 ];then
					displays tomcat[重启]
				else
					displayf tomcat[重启]
				fi
			fi
		fi
	else
		displayf $tomcatpath目录不存在
	fi
}

checkactivemq() {
	status=`ps -ef | grep activemq | awk '{ if ($3 == 1) print $2 }' | wc -l`
	if [ -d $activemqpath ];then
		if [ "$status" -eq 1 ];then
			if [ "$1" == "stop" ]; then
				echo "正在尝试停止activemq服务!"
				$activemqpath/bin/activemq stop &> /dev/null
				if [ $? -eq 0 ];then
					displays activemq[停止]
				else
					displayf activemq[停止]
				fi
			else
				displays avticemq服务正在运行!
			fi
		else
			if [ "$1" == "stop" ]; then
				displays avticemq服务已经停止!
			else
				echo "正在尝试重启activemq服务!"
				$activemqpath/bin/activemq start &> /dev/null
				if [ $? -eq 0 ];then
					displays activemq[重启]
				else
					displayf activemq[重启]
				fi
			fi
		fi
	else
		displayf $activemqpath目录不存在
	fi
}

checkgearmand() {
	status=`ps -ef | grep gearmand | awk '{ if ($3 == 1) print $2 }' | wc -l`
	if [ -d $gearmandpath ];then
		if [ "$status" -eq 1 ];then
			if [ "$1" == "stop" ]; then
				echo "正在尝试停止gearman服务!"
				kill -9 `ps -ef | grep gearmand | awk '{ if ($3 == 1) print $2 }'` &> /dev/null
				if [ $? -eq 0 ];then
					displays gearmand[停止]
				else
					displayf gearmand[停止]
				fi
			else
				displays gearmand服务正在运行!
			fi
		else
			if [ "$1" == "stop" ]; then
				displays gearmand服务已经停止!
			else
				echo "正在尝试重启gearman服务!"
				$gearmandpath/sbin/gearmand --verbose DEBUG --queue-type MySQL --mysql-host rdsaunzvfaunzvf.mysql.rds.aliyuncs.com --mysql-user ppe_admgearman --mysql-password Pp1rds_4323 --mysql-db ppe_dbgearman --mysql-table gearman_queue -d --log-file=$gearmandpath/log/gearman.log
				if [ $? -eq 0 ];then
					displays gearmand[重启]
				else
					displayf gearmand[重启]
				fi
			fi
		fi
	else
		displayf $gearmandpath目录不存在
	fi
}

checkredis() {
	status=`ps -ef | grep redis-server | awk '{ if ($3 == 1) print $2 }' | wc -l`
	if [ -d $redispath ];then
		if [ "$status" -eq 1 ];then
			if [ "$1" == "stop" ]; then
				kill -9 `ps -ef | grep redis-server | awk '{ if ($3 == 1) print $2 }'` &> /dev/null
				if [ $? -eq 0 ];then
					displays redis-server[停止]
				else
					displayf redis-server[停止]
				fi
			else
				displays tomcat服务正在运行!
			fi
		else
			if [ "$1" == "stop" ]; then
				displays tomcat服务已经停止!
			else
				echo "正在尝试重启redis服务!"
				$redispath/bin/redis-server $redispath/etc/redis.conf &> /dev/null
				if [ $? -eq 0 ];then
					displays redis-server[重启]
				else
					displayf redis-server[重启]
				fi
			fi
		fi
	else
		displayf $redispath目录不存在
	fi
}

checkportal() {
	status=`ss -tunlp | grep 8080 | awk '{print $6}' | cut -d, -f2 | wc -l`
	localip=`ifconfig eth0 | sed -n 2p | awk '{print $2}' | cut -d: -f2`
	curl -s http://$localip:8080/ | grep "中国工程科技知识中心" &> /dev/null
	if [ -d $portalpath ];then
		if [ "$status" -eq 1 ] && [ $? -eq 0 ];then
			if [ "$1" == "stop" ]; then
				status=`ss -tunlp | grep 8080 | awk '{print $6}' | cut -d, -f2`
				kill -9 $status
				if [ $? -eq 0 ];then
					displays portal[停止]
				else
					displayf portal[停止]
				fi
			else
				displays portal服务正在运行!
			fi
		else
			if [ "$1" == "stop" ]; then
				displays portal服务已经停止!
			else
				echo "正在尝试重启tomcat服务!"
				$portalpath/bin/startup.sh &> /dev/null
				if [ $? -eq 0 ];then
					displays portal[重启]
				else
					displayf portal[重启]
				fi
			fi
		fi
	else
		displayf $portalpath目录不存在
	fi
}

checkfrontend() {
	status=`ss -tunlp | grep 8089 | awk '{print $6}' | cut -d, -f2 | wc -l`
	localip=`ifconfig eth0 | sed -n 2p | awk '{print $2}' | cut -d: -f2`
	curl -s http://$localip:8089/frontend | grep "WADL" &> /dev/null
	if [ -d $frontendpath ];then
		if [ "$status" -eq 1 ] && [ $? -eq 0 ];then
			if [ "$1" == "stop" ]; then
				status=`ss -tunlp | grep 8089 | awk '{print $6}' | cut -d, -f2`
				kill -9 $status
				if [ $? -eq 0 ];then
					displays frontend[停止]
				else
					displayf frontend[停止]
				fi
			else
				displays frontend服务正在运行!
			fi
		else
			if [ "$1" == "stop" ]; then
				displays frontend服务已经停止!
			else
				echo "正在尝试重启tomcat服务!"
				$frontendpath/bin/startup.sh &> /dev/null
				if [ $? -eq 0 ];then
					displays frontend[重启]
				else
					displayf frontend[重启]
				fi
			fi
		fi
	else
		displayf $frontendpath目录不存在
	fi
}

checkmanager() {
 	status1=`ps -ef | grep com.cekasp.jm.client.MqRdsClient | awk '{ if ($3 == 1) print $2 }' | wc -l`
 	status2=`ps -ef | grep com.cekasp.jm.client.MqRdsResendClient | awk '{ if ($3 == 1) print $2 }' | wc -l`
 	status3=`ps -ef | grep com.cekasp.jm.etl.mq.ViewLoader | awk '{ if ($3 == 1) print $2 }' | wc -l`
	if [ -d $jobmanagerpath ] && [ -d $jobmanager_resendpath ] && [ -d $jobmanager_etlpath];then
		if [ "$status1" -eq 1 ] && [ "$status2" -eq 2 ] && [ "$status3" -eq 3];then
			if [ "$1" == "stop" ]; then
				count=0
				echo "正在尝试停止jobman服务!"
				kill -9 `ps -ef | grep com.cekasp.jm.client.MqRdsClient | awk '{ if ($3 == 1) print $2 }'` &> /dev/null
		 		let count+=$?
		 		kill -9 `ps -ef | grep com.cekasp.jm.client.MqRdsResendClient | awk '{ if ($3 == 1) print $2 }'` &> /dev/null
		 		let count+=$?
		 		kill -9 `ps -ef | grep com.cekasp.jm.etl.mq.ViewLoader | awk '{ if ($3 == 1) print $2 }'` &> /dev/null
				let count+=$?
				if [ $? -eq 0 ];then
					displays jobman[停止]
				else
					displayf jobman[停止]
				fi
			else
				displays jobman服务正在运行!
			fi
		else
			if [ "$1" == "stop" ]; then
				displays jobman服务已经停止!
			else
				count=0
		 		echo "正在尝试重启jobman服务!"
		 		$jobmanagerpath/bin/job-manager.sh start com.cekasp.jm.client.MqRdsClient
		 		let count+=$?
		 		$jobmanager_resendpath/bin/job-manager.sh start com.cekasp.jm.client.MqRdsResendClient
		 		let count+=$?
		 		$jobmanager_etlpath/bin/job-manager.sh start com.cekasp.jm.etl.mq.ViewLoader
		 		let count+=$?
		 		if [ $count -eq 0 ];then
		 			displays jobman[重启]
		 		else
		 			displayf jobman[重启]
		 		fi
			fi
		fi
	else
		displayf $jobmanagerpath或$jobmanager_resendpath或$jobmanager_etlpath目录不存在
	fi
}

checkzookeeper() {
	status=`ps -ef | grep zookeeper | awk '{ if ($3 == 1) print $2 }' | wc -l`
	if [ -d $zookeeperpath ];then
		if [ "$status" -eq 2 ];then
			if [ "$1" == "stop" ]; then
				count=0
				echo "正在尝试停止zookeeper服务!"
				for (( i = 1; i < 3; i++ )); do
					$zookeeperpath/zookeeper$i/bin/zkServer.sh stop &> /dev/null
					let count+=$?
				done
				if [ $? -eq 0 ];then
					displays zookeeper[停止]
				else
					displayf zookeeper[停止]
				fi
			else
				displays zookeeper服务正在运行!
			fi
		else
			if [ "$1" == "stop" ]; then
				displays zookeeper服务已经停止!
			else
				count=0
				echo "正在尝试重启zookeeper服务!"
				for (( i = 1; i < 3; i++ )); do
					$zookeeperpath/zookeeper$i/bin/zkServer.sh start &> /dev/null
					let count+=$?
				done
				if [ $count == 0 ];then
					displays zookeeper[重启]
				else
					displayf zookeeper[重启]
				fi
			fi
		fi
	else
		displayf $zookeeperpath目录不存在
	fi
}

checkltp() {
	status=`ps -ef | grep ltp | awk '{ if ($3 == 1) print $2 }' | wc -l`
	if [ -d $ltppath ];then
		if [ "$status" -eq 1 ]; then
			if [ "$1" == "stop" ]; then
				echo "正在尝试停止ltp服务!"
				$ltppath/scripts/stop.sh
				if [ $? -eq 0 ];then
					displays ltp[停止]
				else
					displayf ltp[停止]
				fi
			else
				displays ltp服务正在运行!
			fi
		else
			if [ "$1" == "stop" ]; then
				displays ltp服务已经停止!
			else
				echo "正在尝试重启ltp服务!"
				$ltppath/scripts/start.sh
				if [ $? -eq 0 ];then
					displays ltp[重启]
				else
					displayf ltp[重启]
				fi
			fi
		fi
	else
		displayf $ltppath目录不存在
	fi
}

checksolr() {
	status=`ps -ef | grep solr | awk '{ if ($3 == 1) print $2 }' | wc -l`
	if [ -d $solrpath ];then
		if [ "$status" -eq 1 ];then
			if [ "$1" == "stop" ]; then
				python $solrpath/scripts/stop.sh &> /dev/null
				if [ $? -eq 0 ];then
					displays solr[停止]
				else
					displayf solr[停止]
				fi
			else
				displays solr服务正在运行!
			fi
		else
			if [ "$1" == "stop" ]; then
				displays solr服务已经停止!
			else
				echo "正在尝试重启solr服务!"
				python $solrpath/scripts/start.sh &> /dev/null
				if [ $? -eq 0 ];then
					displays solr[重启]
				else
					displayf solr[重启]
				fi
			fi
		fi
	else
		displayf $solrpath目录不存在
	fi
}

checkdataprocess() {
	status=`ps -ef | grep dataprocess | awk '{ if ($3 == 1) print $2 }' | wc -l`
	if [ -d $dataprocesspath ];then
		if [ "$status" -eq 2 ];then
			if [ "$1" == "stop" ]; then
				echo "正在尝试停止dataprocess!"
				kill -9 `ps -ef | grep dataprocess | awk '{ if ($3 == 1) print $2 }'` &> /dev/null
				if [ $? -eq 0 ];then
					displays dataprocess[停止]
				else
					displayf dataprocess[停止]
				fi
			else
				displays dataprocess服务正在运行!
			fi
		else
			if [ "$1" == "stop" ]; then
				displays dataprocess服务已经停止!
			else
				echo "正在尝试重启dataprocess!"
				$dataprocesspath/package/scripts/startAll.sh &> /dev/null
				if [ $? -eq 0 ];then
					displays dataprocess[重启]
				else
					displayf dataprocess[重启]
				fi
			fi
		fi
	else
		displayf $dataprocesspath目录不存在
	fi
}

checkcollection() {
	status=`ps -ef | grep datacollection | awk '{ if ($3 == 1) print $2 }' | wc -l`
	if [ -d $datacollectpath ];then
		if [ "$status" -eq 1 ];then
			if [ "$1" == "stop" ]; then
				$datacollectpath/udap/bin/run.sh stop &> /dev/null
				if [ $? -eq 0 ];then
					displays datacollection[停止]
				else
					displayf datacollection[停止]
				fi
			else
				displays datacollection服务正在运行!
			fi
		else
			if [ "$1" == "stop" ]; then
				displays datacollection服务已经停止!
			else
				echo "正在尝试重启datacollection服务!"
				$datacollectpath/udap/bin/run.sh start &> /dev/null
				if [ $? -eq 0 ];then
					displays datacollection[重启]
				else
					displayf datacollection[重启]
				fi
			fi
		fi
	else
		displayf $datacollectpath目录不存在
	fi
}

# checkproxy 检测内容

usage() {
	echo "Usage: checkserivce.sh [模块数字 { base[1] | portal[2] | frontend[3] | jobman[4] | search[5] | datacollection[6] | select[7] 自定义服务启动模式(eg: checkserivce.sh 7 java,portal) | show[8] 自定义服务列表 } ] [start(默认) | stop]"
	echo "示例: checkserivce.sh 1       --->  默认启动base服务所有"
	echo "      checkserivce.sh 1 stop  --->  停止base服务所有"
	echo "      checkserivce.sh 7 java,portal  --->  默认自定义启动java,portal服务"
	echo "      checkserivce.sh 7 java,portal stop  --->  停止自定义java,portal服务"
}

case $1 in
	1)
		displayc
		echo "---------------基础服务检测开始---------------"
		displayc
		checkjava $2
		displayc
		checkactivemq $2
		displayc
		checkgearmand $2
		displayc
		checkredis $2
		displayc
		echo "--------------基础服务检测完毕----------------"
		displayc
		;;
	2)
		displayc
		echo "-----------portal服务/内容检测开始------------"
		displayc
		checkportal $2
		displayc
		echo "-----------portal服务/内容检测完毕------------"
		displayc
		;;
	3)
		displayc
		echo "----------frontend服务/内容检测开始-----------"
		displayc
		checkfrontend $2
		displayc
		echo "----------frontend服务/内容检测完毕-----------"
		displayc
		;;
	4)
		displayc
		echo "-----------jobman服务/内容检测开始------------"
		displayc
		checkmanager $2
		displayc
		echo "-----------jobman服务/内容检测完毕------------"
		displayc
		;;
	5)
		displayc
		echo "-----------search服务/内容检测开始------------"
		displayc
		checkzookeeper $2
		displayc
		checkltp $2
		displayc
		checksolr $2
		displayc
		checkdataprocess $2
		displayc
		echo "-----------search服务/内容检测完毕------------"
		displayc
		;;
	6)
		displayc
		echo "-------datacollection服务/内容检测开始--------"
		displayc
		checkcollection $2
		displayc
		echo "-------datacollection服务/内容检测开始--------"
		displayc
		;;
	7)
		displayc
		echo "------------自定义服务启动模式开始------------"
		displayc
		serviceList=(java portal frontend activemq gearmand redis manager zookeeper ltp solr dataprocess collection)
		if [ ${#2} -gt 0 ];then
			for i in `echo $2 | sed 's/,/ /g'`; do
				check$i $3
				displayc
				if [ $? -gt 0 ]; then
					echo "----------------第二组参数有误----------------"
				fi
			done
		else
			echo "-------------第二参组数不能为空---------------"
		fi
		displayc
		echo "------------自定义服务启动模式结束------------"
		displayc
		;;
	8)
		echo "-------------可自定义的服务列表项-------------"
		echo "java, tomcat (portal , frontend), activemq, gearmand, redis, manager, zookeeper, ltp, solr, dataprocess, collection"
		echo "------------请在第7选项中选择填写-------------"
		;;
	*)
		usage
		;;
esac
