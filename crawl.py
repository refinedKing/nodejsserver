__author__ = 'Administrator'
#coding=utf-8

from sys import argv
from os import makedirs,unlink,sep
from os.path import dirname,exists,isdir,splitext
from string import replace,find,lower
from htmllib import HTMLParser
from urllib import urlretrieve
from urlparse import urlparse,urljoin
from formatter import DumbWriter,AbstractFormatter
from cStringIO import StringIO

# 下载页面
class Retrive(object):
    def __init__(self, url):
        self.url = url
        self.file = self.filename(url)

    def filename(self, url, deffile='index.php'):
        parsedurl = urlparse(url,'http:', 0)
        path = parsedurl[1] + parsedurl[2]
        ext = splitext(path)
        if ext[1] == '':
            if path[-1] == '/':
                path += deffile
            else:
                path += '/' + deffile
        ldir = dirname(path)
        if sep != '/':
            ldir = replace(ldir, '/', sep)
        if not isdir(ldir):
            if exists(ldir):
                unlink(ldir)
            makedirs(ldir)
        return path

    def download(self):
        try:
            retval = urlretrieve(self.url, self.file)
        except IOError:
            retval = 'error'
            return retval

    def parseAndGetLinks(self):
        self.parser = HTMLParser(AbstractFormatter(DumbWriter(StringIO())))
        self.parser.feed(open(self.file).read())
        self.parser.close()
        return self.parser.anchorlist

class Crawler(object):
    count = 0

    def __init__(self, url):
        # 在init函数中构建类的示例参数
        self.q = [url]
        self.seen = []
        self.dom = urlparse(url)[1]

    def getPage(self, url):
        r = Retrive(url)
        retval = r.download()
        if retval[0] == '*':
            print retval, 'sss'
            return
        Crawler.count += 1
        self.seen.append(url)

        links = r.parseAndGetLinks()

        for eachlink in links:
            if eachlink[:4] != 'http' and find(eachlink, '://') == -1:
                eachlink = urljoin(url, eachlink)
            print '* ',eachlink

            if eachlink not in self.seen:
                if find(eachlink, self.dom) == -1:
                    print '  ...discarded,not in domain'
                else:
                    if eachlink not in self.q:
                        self.q.append(eachlink)
                        print ' ...new, added to Q'
                    else:
                        print ' ...discarded,already in Q'
            else:
                print ' ...discarded,process'

    def go(self):
        while self.q:
            url = self.q.pop()
            self.getPage(url)


def main():
    if len(argv) > 1:
        url = argv[1]
    else:
        try:
            url = 'http://www.baidu.com/'
        except (KeyboardInterrupt,EOFError):
            url = ''
    if not url:
        return
    robot = Crawler(url)
    robot.go()

if __name__ == '__main__':
    main()
