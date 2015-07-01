import stackless
import socket
import os
import time

path = os.getcwd() +'\\checkurl'
chan = stackless.channel()
alertlog = os.getcwd() + "\\alert.log"

def input():
    with open(path, 'r') as f:
        for i in f.readlines():
            chan.send(i.split('$')[1])

def output():
    while 1:
        url = chan.receive()
        print url
        s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        try:
            ipip = url.split(':')
            s.connect((ipip[0],int(ipip[1])))
            s.settimeout(20)
            s.close()
        except:
            with open(alertlog, 'a') as fw:
                fw.writelines("telnet disconnected %s  %s\n\n" % (url , time.strftime('%H:%M:%S',time.localtime(time.time()))))

[stackless.tasklet(output)() for i in xrange(28)]
stackless.tasklet(input)()
stackless.run()
