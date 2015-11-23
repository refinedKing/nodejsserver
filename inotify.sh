#!/bin/bash
#

#!/bin/bash
host1=172.16.43.100
src=/var/www/html
dst=/Users/King/test
user=tom
/usr/bin/inotifywait -mrq -e modify,delete,create,attrib /var/www/html/ | while read file
do
/usr/bin/rsync -vzrtopg --delete --progress  --password-file=/etc/rsyncd.passwd $src $user@$host1::$dst
echo "${file} was rsynced" >> /tmp/rsync.log 2>&1
done
