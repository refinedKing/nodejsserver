#coding:utf-8

import requests
import random
import json
import sys

session=requests.session()
session.headers={
    'User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:28.0) Gecko/20100101 Firefox/28.0',
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'Accept-Language': 'zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3',
    'Accept-Encoding': 'deflate',
    'DNT': '1',
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    'X-Requested-With': 'XMLHttpRequest',
    'Referer': 'https://mp.weixin.qq.com/',
    'Connection': 'keep-alive',
    'Pragma': 'no-cache',
    'Cache-Control': 'no-cache'
    }
token=None

def publish(username,pwd):
    """登录"""
    #正确响应：{"base_resp":{"ret":0,"err_msg":"ok"},"redirect_url":"\/cgi-bin\/home?t=home\/index&lang=zh_CN&token=898262162"}
    global token
    url='http://localhost/zentaopms/www/index.php?m=user&f=login'
    data={
          'password':pwd,
          'account':username}
    res=session.post(url,data)
    print 'response: login',res.ok

    url='http://localhost/zentaopms/www/index.php?m=task&f=create&project=1'
    data={
          'assignedTo[]':'B:友友',
          'type':'设计',
          'name':'test',
          }
    res=session.post(url,data)
    print 'response: login',res.text

if __name__=='__main__':
    res=publish('username','password')
    print 'response: login',res
    if not res:
        sys.exit()
