##################################################
##                                              ##
##                    ks.cfg                    ##
##               Centos 7 minimal               ##
##                 version=DEVEL                ##
##                                              ##
##################################################

### System authorization information
auth h --enableshadow --passalgo=sha512
### Install OS instead of upgrade
install
# upgrade
### License agreement:
eula --agreed
# Use CDROM installation media:
cdrom
# disable asking for key on install
key --skip
##				Firewall configuration
#firewall --enabled --service=http,ftp,smtp,ssh
firewall --disabled

##				Run the Setup Agent on first boot
firstboot --disable



##==================== ≠≠≠ ====================##
##				USE MODE INSTALL:
##				Use graphical install:
# graphical
##				Use COMMAND install:
cmdline
##				Use text mode install:
text

##==================== ≠≠≠ ====================##
### Use network installation:
# url --url="https://mirror.yandex.ru/centos/7/os/x86_64"
# url --url="http://mirror.mirohost.net/centos/7/os/x86_64"
# url --url="http://mirrors.bytes.ua/centos/7/os/x86_64"


##				Keyboard layouts
keyboard --vckeymap=us --xlayouts='us','ru' --switch='grp:ctrl_shift_toggle'

		##				System language
		#lang ru_UA.UTF-8


##==================== ≠≠≠ ====================##
##============-Network information-=============##
## Static Network:
# network  --bootproto=static --device=enp1s6 --gateway=192.168.1.2 --ip=192.168.1.10 --nameserver=192.168.1.2 --netmask=255.255.255.0 --noipv6 --activate
# network  --hostname=localhost.localdomain
#### Dynamic Network:
# network  --bootproto=dhcp --noipv6 --activate
# network  --hostname=localhost.localdomain
#### Dynamic Network NNSERVER:
# network  --bootproto=dhcp --noipv6 --activate
# network  --hostname=localhost.nnserver

##==================== ≠≠≠ ====================##
## Network information
network  --bootproto=static --device=enp1s6 --gateway=192.168.1.2 --ip=192.168.1.10 --nameserver=192.168.1.2 --netmask=255.255.255.0 --noipv6 --activate
network  --bootproto=dhcp --hostname=localhost.localdomain


##==================== ≠≠≠ ====================##
## Reboot after installation:
## Перезагрузка и извлечь  носитель (DVD):
# reboot --eject		

## Перезагрузка в обход BIOS/прошивки и загрузчика:
reboot --kexec			


##==================== ≠≠≠ ====================##
##=======-SSH-сервер, USER, SSH key-============##

## SSH-SERV во время установки.(ДОБАВИТЬ В ФАЙЛ ISOLYNUX inst.sshd ):
sshpw --username=root --iscrypted $6$f2n6gO8NYOQ/wI5.$zaDGRl7tO5GHu16KsdNtwWJcgj4nEnw3Ytjvwr591y48ABxWnazD/M.MsyiccOBqtGfrsgMoxaISS3YiOHhxb/

## Root password
rootpw --iscrypted $6$f2n6gO8NYOQ/wI5.$zaDGRl7tO5GHu16KsdNtwWJcgj4nEnw3Ytjvwr591y48ABxWnazD/M.MsyiccOBqtGfrsgMoxaISS3YiOHhxb/

## User password
user --groups=wheel --name=admin --password=$6$YuSrk/AgCfc1C1n7$61Yg/tsJch5nTjZj0SH0YUOmK9rAMWan6TDGH1xi85lYAqTIChdgbsjh/in693mq7Bp/yk9d6vTL0VBJ0Ba7o1 --iscrypted --gecos="Admin"

## SELinux configuration
selinux --disabled

## SSH-KEY:
sshkey --username=root "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKp3bxeApwQec9N6DaIP1Iq3o7Ks4jcL66wHi1YdqkFC root"
sshkey --username=admin "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3nyIJFszoNVmLolr3gV+yOJyCT+0ImsOH/C3rZloR4 admin"




##==================== ≠≠≠ ====================##
##===============System services================##
## System services:
services --enabled="chronyd"
# services --disabled=autofs,alsa-state,avahi-daemon,bluetooth,pcscd,cachefilesd,colord,fancontrol,fcoe,firewalld,firstboot-graphical,gdm,httpd,initial-setup,initial-setup-text,initial-setup-graphical,initial-setup-reconfiguration,kdump,libstoragemgmt,ModemManager,tog-pegasus,tmp.mount,tuned \
# --enabled=bacula-fd,chronyd,edac,gpm,numad,rsyslog,sendmail,smartd,sm-client,sssd,zabbix-agent
#services --disabled=NetworkManager
## Do not configure the X Window System
skipx
## System timezone
timezone Europe/Kiev --isUtc --ntpservers=3.centos.pool.ntp.org,ua.pool.ntp.org,0.centos.pool.ntp.org,2.centos.pool.ntp.org,1.centos.pool.ntp.org


		##******************** INFO ********************##
		#* rootpw —lock   # — запрет подключения к серверу root-ом
		#-$ python -c 'import crypt; print(crypt.crypt("My Password", "$6$My Salt"))'
		#*
		#* Пароль пользователя root и админ можно сгенерировать заранее";
		#* python -c "import crypt,random,string; print crypt.crypt(\"my_password\", '\$6\$' + ''.join([random.choice(string.ascii_letters + string.digits) for _ in range(16)]))" ;
		##******************** INFO ********************##


##==================== ≠≠≠ ====================##
##============ Package installation ===========##
#### packages install:
%packages --ignoremissing
	@^minimal
	@core
	chrony
	kexec-tools
	kexec-tools
%end


##==================== ≠≠≠ ====================##
##===============-Select profile-===============##
##				Profile:
%addon org_fedora_oscap
    content-type = scap-security-guide
    profile = xccdf_org.ssgproject.content_profile_pci-dss
%end


##==============================================##
##				KDump:
%addon com_redhat_kdump --enable --reserve-mb='auto'

%end


##==============================================##
##				Policy:
%anaconda
	pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
	pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
	pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end


##==================== ≠≠≠ ====================##
##================ Pre Install ================##
##==================== ≠≠≠ ====================##
## Выполнение скрипта перед установкой:

%pre --interpreter /bin/sh
#sleep 2
#Chip

#!/bin/sh

# assumes all disks for install are on the scsi bus
echo "pre kickstart script is running" > ./tmp/pre-kickstart.out
#echo "pre kickstart script is running" > .\pre-kickstart.out
#				path for file
#outfile='.\part-include'
outfile='/tmp/part-include'
echo "####" > "$outfile"



##==============================================##
get_disk_paths() {
	for d in `echo /sys/bus/scsi/devices/*`;
	do
		   [ -d $d/block* ] && echo $d/block*
	done
}

convert_path_to_dev_name() {
	echo $1 | sed -e 's/^.*block\://'
}

get_queue_type() {
	file=$(dirname $1)/queue_type
	if [ -f $file ]; then
		   cat $file
	else
		   echo "no queue type"
	fi
}

get_disk_size() {
	file=$1/size
	if [ -f $file ]; then
		   cat $file
	else
		   echo 0
	fi
}

is_removable() {
	cat $1/removable
}


all_disks=$(get_disk_paths)
all_dev_names=$(for d in $all_disks; do convert_path_to_dev_name $d;
done)

#echo $all_disks
#echo $all_dev_names

install_disk=""
install_dev=""
install_home=""
for dev in $all_disks;
do
#here is our test for USB flash device
#No queuing and is_removable
	if [ $(get_queue_type $dev) == "none" ] && [ $(is_removable
$dev) -eq 1 ] ;then
		install_disk=$dev
		install_dev=$(convert_path_to_dev_name $dev)
		install_home="sdg"
	fi
done

##==================== ≠≠≠ ====================##
#no USB flash device use all of first disk
if [ -z "$install_disk" ]; then
	$install_disk=$(echo $all_disk | cut -d' ' -f1)
	$install_dev=$(convert_path_to_dev_name $install_disk)
fi
install_dev_size=$(get_disk_size $install_disk)

#echo $install_disk
#echo $install_dev
#echo $install_dev_size

#echo $install_home

size_kblks=$[ $install_dev_size / 2 ]
size_Mblks=$[ size_kblks / 1000 ]
boot_size=1022
biosboot_size=2
swap_size=8196
root_size=$[ $size_Mblks - $boot_size - $swap_size ]
home_size=$[ $root_size - $size_Mblks - $boot_size - $swap_size ]




## Розметка диска:

##==================== ≠≠≠ =====================##
	cat <<EOF >$outfile
##==================== ≠≠≠ =====================##
	## Clear the Master Boot Record:
zerombr

	#partitioning info starts here
clearpart --drives=$(echo $all_dev_names | tr ' ' ,) --all --initlabel
ignoredisk --drives=$(echo ${all_dev_names/$install_dev/} | tr ' ' ,  )

part /boot    --fstype=ext2 --ondisk=$install_dev --size=$boot_size --label=BOOT --asprimary
part biosboot --fstype="biosboot" --ondisk=$install_dev --size=$biosboot_size --asprimary
part swap     --fstype=swap --ondisk=$install_dev --size=$swap_size --asprimary
part /        --fstype=ext3 --size=$root_size --grow --ondisk=$install_dev --asprimary
part /home    --fstype=ext3 --size=$home_size --grow --ondisk=$install_dev

#autopart
# System bootloader configuration
bootloader --append="rhgb quiet crashkernel=128M 16M console=tty1
console=ttyS0,38400n8" --location=mbr --driveorder=$install_dev

EOF

##==================== ≠≠≠ ====================##
##================-Post Install-================##
##==================== ≠≠≠ ====================##

#### Выполнение скрипта после установки:
%post
	# yum install -y policycoreutils-python
	echo "admin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/admin
	## Change ssh port:
	# /usr/bin/sed -i "s%#Port 22%Port 43389%g" "/etc/ssh/sshd_config"
	# /usr/bin/sed -i "s%#PermitRootLogin yes%PermitRootLogin no%g" "/etc/ssh/sshd_config"
	# /sbin/semanage port -a -t ssh_port_t -p tcp 22822
	# /usr/bin/firewall-cmd --permanent --zone=public --remove-service=ssh
#%end

##==================== ≠≠≠ ====================##
chkconfig httpd on
# modify grub for serial console
sed -i -e 's/^timeout=5/serial --unit=0 --speed=38400 --word=8
--parity=no --stop=1 \
terminal --timeout=5 serial console \
timeout=5/' /boot/grub/grub.conf

##==================== ≠≠≠ ====================##
# modify inittab to add serial console login
cat >>/etc/inittab <<EOF

##==================== ≠≠≠ ====================##
#serial console login enabled
co:2345:respawn:/sbin/agetty ttyS0 38400 vt100-nav
EOF

# add tmpfs mounts
cat >>/etc/fstab<<EOF
tmpfs                   /tmp                tmpfs   size=20M       0 0
tmpfs                   /var/tmp            tmpfs   size=2M        0 0
tmpfs                   /var/run            tmpfs   size=2M        0 0
EOF
# update for noatime
sed -i -e '1,2s/defaults/defaults,noatime,nodiratime/' /etc/fstab

# get host info
GATEWAY=$(route -n | grep ^0.0.0.0 | awk '{print $2}')
#HOSTNAME=$(hostname)
HOSTIP=$(ifconfig eth0 | grep "inet addr" | cut -d: -f2|awk '{print
$1}')
NETMASK=$(ifconfig eth0 | grep Mask | cut -d: -f4)
HOSTNAME=$(host $HOSTIP 5.5.64.127 | grep pointer | cut -d' ' -f 5 |
cut -d. -f1 )
#FQDN=$(host $HOSTNAME 5.5.64.127 | grep address | cut -d' ' -f1)
if [ -z "$HOSTIP" ] ; then
	echo "Did not find a IP address for host $HOSTNAME from
Server:$DNS!"
	echo "This will need to be set manually"
fi
#echo write hosts file
#echo "$HOSTIP $FQDN $HOSTNAME" >> /etc/hosts
# update network file for gateway
echo "GATEWAY=$GATEWAY" >>/etc/sysconfig/network
echo update ifcfg-eth0 for static
( cd /etc/sysconfig/network-scripts
sed -i -e "s/dhcp/static/" ifcfg-eth0
cat >>ifcfg-eth0 <<EOF
IPADDR=$HOSTIP
NETMASK=$NETMASK
EOF
)
# make netreport to quiet network startup
echo "mkdir -p /var/run/netreport" >> /etc/rc.d/rc.sysinit

# update other ethernet interfaces
HOSTNUM=$[ $(echo $HOSTNAME |  perl -ln -e '/([1-9]+)$/; print "$1";') %
255]
for e in 2 3 4 5 6 7 8 9
do
        file=/etc/sysconfig/network-scripts/ifcfg-eth${e}
        if [ -e $file ] ; then
		netnum=$[ ${e} + 100 ]
                sed  -i -e "s/ONBOOT=no/ONBOOT=yes\n\
IPADDR=172.25.${HOSTNUM}.${netnum} \n\
NETMASK=255.255.0.0 \n\
BOOTPROTO=static \
/" $file
		if [ ${e} -eq 2 ]; then
			cat >/etc/ethers.eth${e}<<EOF_ETHERS
#nsg ethers
00:00:00:00:00:05 172.25.100.3
00:00:00:00:00:05 172.25.100.2
EOF_ETHERS
		else
			( cd /etc
			 ln -s ethers.eth2 ethers.eth${e}
			)
		fi
	fi
done
sync

%include "$outfile"














##==================== ≠≠≠ ====================##
### РУЧНАЯ:
## Disk partitioning information
##-------------------1 drives-------------------##
		## partitioning scheme generated in %pre for 1 drives
		# part biosboot --fstype="biosboot" --ondisk=sda --size=2
		# part pv.699 --fstype="lvmpv" --ondisk=sda --size=304220
		# part /boot --fstype="ext4" --ondisk=sda --size=1022 --label=BOOT
		# volgroup centos00 --pesize=4096 pv.699
		# part swap --fstype="swap" --size=8196
		# logvol /  --fstype="xfs" --size=111700 --label=ROOT --vgname=centos00
		# logvol /home  --fstype="xfs" --size=184320 --label=HOME --vgname=centos00 --grow


##-------------------2 drives-------------------##
		## partitioning scheme generated in %pre for 2 drives
		# part biosboot --fstype=biosboot --size=2 --ondisk=sda
		# part /boot --fstype=ext4 --size=1022 --label=BOOT --ondisk=sda
		# part swap --fstype=swap --size=8196 --ondisk=sda
		# part / --fstype=ext4 --size=111700 --grow --ondisk=sda
		# part /home --fstype=ext4 --size=184320 --grow --ondisk=sdg
##==================== ≠≠≠ ====================##





##================ INFORMATION ================##
##==================== ≠≠≠ ====================##
##
## hds="" 
## mymedia=""  
## for file in /proc/ide/h* do   
## 	mymedia=`cat $file/media`   
## 	if [ $mymedia == "disk" ] ; then       
## 		hds="$hds `basename $file`"   
## 	fi 
## done
## 
## set $hds 
## numhd=`echo $#`  
## drive1=`echo $hds | cut -d' ' -f1` 
## drive2=`echo $hds | cut -d' ' -f2`  
## #Write out partition scheme based on whether there are 1 or 2 hard drives  
## if [ $numhd == "2" ] ; then
##
##==================== ≠≠≠ ====================##
##===============  partitioning  ==============##
##		2 drives
#cat > /tmp/part-include <<EOF
#clearpart --all
#part biosboot --fstype=biosboot --size=2 --ondisk=sda
#part /boot --fstype=ext4 --size=1022 --label=BOOT --ondisk=sda
#part swap --fstype=swap --size=8196 --ondisk=sda
#part / --fstype=ext4 --size=111700 --grow --ondisk=sda
#part /home --fstype=ext4 --size=184320 --grow --ondisk=sdg
#EOF
##
## 	else
##
##
## #======partitioning %pre for 1 drives ==========#
##==================== ≠≠≠ ====================##
##		1 drives
#cat > /tmp/part-include <<EOF
#clearpart --all
#part biosboot --fstype=biosboot --size=2 --ondisk=sda
#part /boot --fstype=ext4 --size=1022 --ondisk=sda
#part swap --fstype=swap --size=8196
#part /  --fstype=xfs --size=111700 --label=ROOT --grow
#part /home  --fstype=xfs --size=184320 --label=HOME --grow
#EOF
## fi
##
##==================== ≠≠≠ ====================##


