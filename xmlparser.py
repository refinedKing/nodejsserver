# coding=utf-8

import lxml.html
import requests
import sys

def activemq():
	args1list = ['urn','rdsupdate','JobManager.jobs','JobManager.loader','JobManager.return','MetaData']
	args2list = ['size','consumercount','enqueuecount','dequeuecount']
	
	req = requests.request('GET', 'xxxxx',auth=('admin', 'admin'))
	doc = lxml.html.document_fromstring(req.text)
	mylist = []
	for idx, el in enumerate(doc.xpath(u'//stats')):
	    mylist.append(el.attrib)
	print mylist
	print mylist[args1list.index(sys.argv[2])][sys.argv[3]]

def gearman():
	gearlist = ['gearman_queue','job_queue']
	path = '/usr/local/gearman_backlog.log'
	with open(path,'r') as f:
		for index,i in enumerate(f.readlines()):
			if gearlist.index(sys.argv[2]) == index:
				print i

if __name__ == '__main__':
	if sys.argv[1] == 'activemq':
		activemq()
	else:
		gearman()
