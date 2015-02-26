#!/usr/bin/env python
# -*- coding: utf-8 -*-
import json
import urllib2
import sys
import base64

class zabbixtools:
    def __init__(self):
        self.url = "http://xxx.xxx.xxx.xxx/api_jsonrpc.php"
        self.header = {"Content-Type": "application/json"}
        self.webusername = 'smoke'
        self.webpassword = 'password'
        self.authID = self.user_login()
    def user_login(self):
        data = json.dumps(
                {
                    "jsonrpc": "2.0",
                    "method": "user.login",
                    "params": {
                        "user": "admin",
                        "password": "cekasp!@#$%"
                        },
                    "id": 1
                    })
        request = urllib2.Request(self.url,data)
        request.add_header('Authorization', b'Basic ' + base64.b64encode(self.webusername + b':' + self.webpassword))
        for key in self.header:
            request.add_header(key,self.header[key])
        try:
            result = urllib2.urlopen(request)
        except urllib2.URLError as e:
            print "Auth Failed, Please Check Your Name And Password:",e.code
        else:
            response = json.loads(result.read())
            result.close()
            authID = response['result']
            return authID
    def get_data(self,data,hostip=""):
        request = urllib2.Request(self.url,data)
        request.add_header('Authorization', b'Basic ' + base64.b64encode(self.webusername + b':' + self.webpassword))
        for key in self.header:
            request.add_header(key,self.header[key])
        try:
            result = urllib2.urlopen(request)
        except urllib2.URLError as e:
            if hasattr(e, 'reason'):
                print 'We failed to reach a server.'
                print 'Reason: ', e.reason
            elif hasattr(e, 'code'):
                print 'The server could not fulfill the request.'
                print 'Error code: ', e.code
            return 0
        else:
            response = json.loads(result.read())
            result.close()
            return response
    def template_get(self):
        data = json.dumps(
                {
                    "jsonrpc": "2.0",
                    "method": "template.get",
                    "params": {
                        "output": "extend",
                        },
                    "auth": self.authID,
                    "id": 1,
                    })
        
        res = self.get_data(data)#['result']
        if 'result' in res.keys():
            res = res['result']
            if (res !=0) or (len(res) != 0):
                print "\033[1;32;40m%s\033[0m" % "Number Of Template: ", "\033[1;31;40m%d\033[0m" % len(res)
                for host in res:
                    print "\t","Template_id:",host['templateid'],"\t","Template_Name:",host['name'].encode('GBK')
            return res
        else:
            print "Get Template Error,please check !"
    def items_get(self,hostid,interfaceid):
        data = json.dumps(
                {
                    "jsonrpc": "2.0",
                    "method": "item.get",
                    "params": {
                        "output": "extend",
                        "sortfield": "name",
                        "filter": {
                                "hostid": hostid,
                                "interfaceid": interfaceid
                            }
                        },
                    "auth": self.authID,
                    "id": 1
                })
        return self.get_data(data)['result']
    def host_get(self,hostname):
        #hostip = raw_input("\033[1;35;40m%s\033[0m" % 'Enter Your Check Host:Host_ip :')
        data = json.dumps(
                {
                    "jsonrpc": "2.0",
                    "method": "host.get",
                    "params": {
                        "output":["hostid","name","status","host"],
                        "filter": {
                                "host": hostname
                            }
                        },
                    "auth": self.authID,
                    "id": 1
                })
        res = self.get_data(data)['result']
        if (res != 0) and (len(res) != 0):
            for host in res:
                #host = res[0]
                if host['status'] == '1':
                    print "\t","%s" % "Host_IP:","%s" % host['host'].ljust(15),'\t',"%s" % "Host_Name:","%s" % host['name'],'\t',"%s" % u'未在监控状态'
                elif host['status'] == '0':
                    print "\t","%s" % "Host_IP:","%s" % host['host'].ljust(15),'\t',"%s" % "Host_Name:","%s" % host['name'],'\t',"%s" % u'在监控状态'
            return host['hostid']
        else:
            print '\t',"%s" % "Get Host Error or cannot find this host,please check !"
            return 0
    def interface_get(self,hostid):
        data = json.dumps(
                {
                    "jsonrpc": "2.0",
                    "method": "hostinterface.get",
                    "params": {
                        "output": "extend",
                        "hostids": hostid,
                        "filter": {
                            "type": "4"
                        }
                    },
                    "auth": self.authID,
                    "id": 1
                })
        res = self.get_data(data)["result"]
        return res
    def items_create(self, delay, hostid, interfaceid, key_, name, type, value_type, appid):
        data = json.dumps(
                {
                    "jsonrpc": "2.0",
                    "method": "item.create",
                    "params": {
                        "name": name,
                        "key_": key_,
                        "hostid": hostid,
                        "type": type,
                        "interfaceid": interfaceid,
                        "value_type": value_type,
                        "delay": 30,
                        "applications": appid
                    },
                    "auth": self.authID,
                    "id": 1
                })
        res = self.get_data(data)
        return res
    def app_get(self, hostid):
        data = json.dumps({
            "jsonrpc": "2.0",
            "method": "application.get",
            "params": {
                "output": "extend",
                "hostids": hostid,
                "sortfield": "name"
            },
            "auth": self.authID,
            "id": 1
        })
        res = self.get_data(data)["result"]
        print res
    def app_create(self, name, hostid):
        data = json.dumps({
            "jsonrpc": "2.0",
            "method": "application.create",
            "params": {
                "name": name,
                "hostid": hostid
            },
            "auth": self.authID,
            "id": 1
        })
        res = self.get_data(data)["result"]
        return res["applicationids"]

if __name__ == "__main__":
    test = zabbixtools()

    data = []
    interface = []
    names = ["frontendback","monitor"]
    ports = ["8090","8099"]
    hostid = test.host_get("pe002")
    for index,i in enumerate(test.interface_get(hostid)):
        if i['port'] == "12345":
            data = test.items_get(hostid, i["interfaceid"])
        else:
            interface.append(i["interfaceid"]+":"+i["port"]+":"+names[index-1]+":"+ports[index-1])

    for index, i in enumerate(interface):
        interfaceid = i.split(":") #interface[0][:3]
        appid = test.app_create("jmx_"+interfaceid[1], hostid)
        for j in data:
            space = index % 2 == 0 and " " or "  "
            pos = j["key_"].rfind(",") + 1
            keys = j["key_"][0:pos] + space + j["key_"][pos:]
            if j["key_"][0:pos].rfind("frontend") > 0:
                keys = j["key_"][0:pos].replace("frontend",interfaceid[2]) + space + j["key_"][pos:]

            if j["key_"][0:pos].rfind("8089") > 0:
                keys = j["key_"][0:pos].replace("8089",interfaceid[3]) + space + j["key_"][pos:]

            print test.items_create(int(j["delay"]), j["hostid"], interfaceid[0], keys, j["name"]+":"+interfaceid[1], int(j["type"]), int(j["value_type"]), appid)
