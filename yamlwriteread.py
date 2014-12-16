# coding=utf-8
import os
# easy_install pyyaml
import yaml

yaml = open('version.sls')
versionlist = yaml.load(yaml)

c = [ j for i in os.listdir('../../salt/files') for j in versionlist['version'] if str(i).__contains__(j) ]
a = list(set(c))
a.sort(key=c.index)

b = [ str(i)[str(i).rindex('-')+1: str(i).rindex('.')] for i in os.listdir('../../salt/files')]

c = dict(zip(a,b))

class MagicDict(dict):
    def __init__(self, **kwargs):
        dict.__init__(self, kwargs)
        self.__dict__ = self
 
    def __getattr__(self, name):
        self[name] = MagicDict()
        return self[name]

d = MagicDict()
d.version = c
print d

stream = file('document.yaml', 'w')
yaml.dump(versionlist, stream)
