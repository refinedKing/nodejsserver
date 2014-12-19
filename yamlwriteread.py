import os
import yaml

def run():
	# __opts__['pillar_roots']['base'][0]
	# __opts__['file_roots']['base'][0]
	a = [ str(i)[0: str(i).rindex('-')] for i in os.listdir(__opts__['pillar_roots']['base'][0] + '/../salt/files')]
	b = [ str(i)[str(i).rindex('-')+1: str(i).rindex('.')] for i in os.listdir(__opts__['pillar_roots']['base'][0] + '/../salt/files')]
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

	stream = file(__opts__['pillar_roots']['base'][0] + '/common/version.sls', 'w')
	yaml.dump(dict(d), stream, default_flow_style=False)
	return {'buildversion' : 'success'}
