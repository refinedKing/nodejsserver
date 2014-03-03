import urllib
url = [''] * 50
page = 1
link = 1
while page <= 7:
	con = urllib.urlopen('http://blog.sina.com.cn/s/articlelist_1191258123_0_'+str(page)+'.html').read()
	i = 0
	page = page + 1
	title = con.find(r'<a title=')
	href = con.find(r'href=', title)
	html = con.find(r'.html', href)
	while title != -1 and href != -1 and html != -1 and i < 50:
		url[i] = con[href + 6:html + 5]
		link = link + 1 
		#print str(link) +',' +url[i]
		content = urllib.urlopen(url[i]).read()
		filename = 'd:/blog/' + url[i][-26:]
		open(filename, 'w').write(content)

		title = con.find(r'<a title=',html)
		href = con.find(r'href=', title)
		html = con.find(r'.html', href)
		i = i + 1
	else:
		print 'find end'
