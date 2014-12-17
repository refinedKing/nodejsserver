import os
import salt.config
import salt.loader

def path():
	__opts__ = salt.config.minion_config('/etc/salt/minion')
	__grains__ = salt.loader.grains(__opts__)
	hostname = __grains__['host']
	hosttype = ''
	
	if str(hostname).__contains__('vpn'):
		hosttype = 'vpn'
	elif str(hostname).__contains__('alihzppe'):
		hosttype = 'alihzppe'
	elif str(hostname).__contains__('alihzqa'):
		hosttype = 'alihzqa'
	elif str(hostname).__contains__('alihzprod'):
		hosttype = 'alihzprod'
	else:
		hosttype = ''

	JAVA_HOME = '/data01/jdk'
	path = '/data01/jdk/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin'
	return {'JAVA_HOME': JAVA_HOME, 'path': path, 'hosttype': hosttype}

if __name__ == "__main__":
	print path()
