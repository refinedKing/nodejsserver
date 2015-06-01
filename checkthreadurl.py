import os
import threading
import socket
import Queue
import time

alertlog = os.getcwd() + "\\alert.log"

queue = Queue.Queue()
path = os.getcwd() +'\\checkurl'
_thread = 28
with open(path,'r') as f:
	for i in f.readlines():
		mystr = i.split('$')
		queue.put(mystr[1])

def portcheck(i,q):
	while True:
		if queue.qsize() <= 0:
			break
		s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
		try:
			ip = q.get()
			ipip = ip.split(':')
			s.connect((ipip[0],int(ipip[1])))
			s.settimeout(20)
			s.close()
			return True
		except:
			with open(alertlog, 'a') as fw:
	 			fw.writelines("telnet disconnected %s--%s\n\n" % (ip , time.strftime('%Y-%m-%d %H:%M:%S %Z',time.localtime(time.time()))))
		finally:
			q.task_done()

for i in range(_thread):
	print "开始前:" + str(queue.qsize())
	run=threading.Thread(target=portcheck,args=(i,queue)) 
	run.start()
	print "start:" + str(queue.qsize())
queue.join()
