#!/bin/bash
#

#!/bin/bash
#

[ -e "/root/myiso/Packages" ] || mkdir -p /root/myiso/Packages

cd /root/myiso/Packages
for i in `cat /root/install.log | grep "^Installing" | awk '{print $2}'`; do
	echo "$i"
	#[ -e /media/Packages/"$i" ] && cp /media/Packages/"$i" /root/myiso/Packages
	[ -e /media/Packages/"$i".rpm ] && wget -qnc http://172.16.0.1/cobbler/ks_mirror/centos-6.5-x86_64/Packages/"$i".rpm
done

cd /root
createrepo /root/myiso/Packages &> /dev/null
#mv /root/myiso/Packages/repodata/ /root/myiso/

[ -e "/root/myiso/isolinux" ] || mkdir -p /root/myiso/isolinux
cd /root/myiso/isolinux	
echo "mirror" | lftp "http://172.16.0.1/cobbler/ks_mirror/centos-6.5-x86_64/isolinux" 

[ -e "/root/myiso/images" ] || mkdir -p /root/myiso/images
cd /root/myiso/images	
echo "mirror" | lftp "http://172.16.0.1/cobbler/ks_mirror/centos-6.5-x86_64/images"

[ -e "/root/myiso/EFI" ] || mkdir -p /root/myiso/EFI
cd /root/myiso/EFI	
echo "mirror" | lftp "http://172.16.0.1/cobbler/ks_mirror/centos-6.5-x86_64/EFI"

cd /root/myiso
#wget -qnc http://172.16.0.1/cobbler/ks_mirror/centos-6.5-x86_64/CentOS_BuildTag
#wget -qnc http://172.16.0.1/cobbler/ks_mirror/centos-6.5-x86_64/EULA
#wget -qnc http://172.16.0.1/cobbler/ks_mirror/centos-6.5-x86_64/GPL
#wget -qnc http://172.16.0.1/cobbler/ks_mirror/centos-6.5-x86_64/RELEASE-NOTES-en-US.html
#wget -qnc http://172.16.0.1/cobbler/ks_mirror/centos-6.5-x86_64/RPM-GPG-KEY-CentOS-6
#wget -qnc http://172.16.0.1/cobbler/ks_mirror/centos-6.5-x86_64/RPM-GPG-KEY-CentOS-Debug-6
#wget -qnc http://172.16.0.1/cobbler/ks_mirror/centos-6.5-x86_64/RPM-GPG-KEY-CentOS-Security-6
#wget -qnc http://172.16.0.1/cobbler/ks_mirror/centos-6.5-x86_64/RPM-GPG-KEY-CentOS-Testing-6
#wget -qnc http://172.16.0.1/cobbler/ks_mirror/centos-6.5-x86_64/.treeinfo
#wget -qnc http://172.16.0.1/cobbler/ks_mirror/centos-6.5-x86_64/.discinfo

cp /root/iso.cfg /root/myiso/iso.cfg

sed -i "s/\(^[[:space:]]\{2\}append.*img$\)/\\1 ks=cdrom:\/iso.cfg/" /root/myiso/isolinux/isolinux.cfg

cd /root/myiso
mkisofs -R -J -T -v --no-emul-boot --boot-load-size 4 --boot-info-table -V "CentOS 6.5 x86_64 boot" -b isolinux/isolinux.bin -c isolinux/boot.cat -o /root/centos6.5.iso  ~/myiso
