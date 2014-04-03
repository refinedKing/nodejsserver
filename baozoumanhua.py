#!/usr/bin/env python3
import urllib.request
import re
import os
import time

mainSite='http://baozoumanhua.com/all/day/page/'
folder=os.path.join('result',time.strftime("%Y-%m-%d", time.localtime()))
regex=re.compile(r'(?<=src=").*?"')
extList=['.jpg','.gif','.png']

def downloadOne(url):
	# print(urllib.request.urlopen(url).read())
	for i in regex.findall(urllib.request.urlopen(url).read().decode('utf-8')):
		if i.find('sinaimg')!=-1:
			savePic(i)

def savePic(url):
	try:
		print(url)
		filename=url[url.rfind('/')+1:-1]
		if os.path.splitext(filename)[1] in extList:
			with open(os.path.join(folder,filename),'wb') as f:
				f.write(urllib.request.urlopen(url).read())
	except Exception:
		pass

def main():
	if not os.path.exists(folder):
		os.makedirs(folder)
	for i in range(1,20):
		downloadOne(mainSite+str(i))

if __name__=='__main__':
	main()
