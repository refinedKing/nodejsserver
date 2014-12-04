# coding=utf-8
import requests
import json
import datetime
import random
url = "http://www.ckcest.zju.edu.cn/tcm/search/frontresultlist"
#url = "http://www.twitter.com"
key = ("当归", "人参", "枸杞")
payload = {
	"keyword": key[random.randint(0,2)],
	"type": "单味药",
	"pageno": 1,
	"pagesize": 1
}
begintime = datetime.datetime.now()
headers = {'content-type': 'application/json'}
try:
	r = requests.post(url, data=json.dumps(payload), headers=headers, timeout=10)
	#print r.status_code
	#print r.text
	endtime = datetime.datetime.now()
	print float(str((endtime - begintime).seconds) +"."+ str((endtime - begintime).microseconds/1000))
except requests.ConnectionError,e:
	print 30
except requests.Timeout,e:
	print 30
except requests.HTTPError,e:
	print 30
