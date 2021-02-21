##################################################
##                                              ##
##                    ks.cfg                    ##
##               Centos 7 minimal               ##
##                 version=DEVEL                ##
##                                              ##
##################################################
#platform=x86, AMD64, or Intel EM64T
# System authorization information
auth  --useshadow  --enablemd5
# Clear the Master Boot Record
zerombr
#dynamic drive install
# cmdline causes no-interaction installs
cmdline
# Use text install
text
# use graphical install
# graphical
# disable asking for key on install
key --skip
# Firewall configuration
firewall --disabled
# Run the Setup Agent on first boot
firstboot --disable
# System keyboard
keyboard us
# System language
lang en_US
# Installation logging level
logging --level=info
# Install OS instead of upgrade
install
# Use network installation
# area51
# CD Image loop mounted or copied (must match booted image)
url --url=http://10.109.0.46/repo/RHEL5/VOD
repo --name=packages --baseurl=http://10.109.0.46/packages
repo --name=EL5-latest --baseurl=http://10.109.0.46/repo/RHEL5/x86_64/
# Network information

# SELinux configuration
selinux --disabled
# System timezone
timezone --isUtc America/Los_Angeles
# X Window System configuration information
#xconfig  --defaultdesktop=GNOME --depth=8 --resolution=800x600 --startxonboot
#reboot
%packages --nobase
kernel
bash
passwd
mkinitrd
grub
coreutils
httpd
openssh-server
openssh-clients
ftp
kexec-tools
rootfiles
sudo
sysklogd
smartmontools
yum
ntp
mdadm
traceroute
strace
man
bind-utils
tcpdump
logrotate
audit


# extra tools
sysstat
gdb
vim-minimal
which

#remove un-used packages
-libhugetlbfs.i386
-libtermcap.i386
-system-config-securitylevel-tui
-policycoreutils
-librpm.i386
-zlib.i386
-sqlite.i386
-beecrypt.i386
-elfutils-libelf.i386
-sysreport
-rp-pppoe
-NetworkManager
-aspell*
-words
-bluez*
-ypbind
-yptools
-nc


%pre --interpreter /bin/sh
#!/bin/sh
# assumes all disks for install are on the scsi bus
echo "pre kickstart script is running" >/tmp/pre-kickstart.out
#path for file
outfile=/tmp/part-include

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
all_dev_names=$(for d in $all_disks; do convert_path_to_dev_name $d; done)

#echo $all_disks
#echo $all_dev_names

install_disk=""
install_dev=""
for dev in $all_disks;
do
#here is our test for USB flash device
#No queuing and is_removable
	if [ $(get_queue_type $dev) == "none" ] && [ $(is_removable $dev) -eq 1 ] ;then
		install_disk=$dev
		install_dev=$(convert_path_to_dev_name $dev)
	fi
done

#no USB flash device use all of first disk
if [ -z "$install_disk" ]; then
	$install_disk=$(echo $all_disk | cut -d' ' -f1)
	$install_dev=$(convert_path_to_dev_name $install_disk)
fi
install_dev_size=$(get_disk_size $install_disk)

#echo $install_disk
#echo $install_dev
#echo $install_dev_size
size_kblks=$[ $install_dev_size / 2 ]
size_Mblks=$[ size_kblks / 1000 ]
boot_size=100
swap_size=500
root_size=$[ $size_Mblks - $boot_size - $swap_size ]

cat <<EOF >$outfile
#partitioning info starts here
clearpart --drives=$(echo $all_dev_names | tr ' ' ,) --all --initlabel
ignoredisk --drives=$(echo ${all_dev_names/$install_dev/} | tr ' ' ,  )

part /    --fstype=ext3 --ondisk=$install_dev --size=$root_size --asprimary
part /boot --fstype=ext2 --ondisk=$install_dev --size=$boot_size --asprimary
part swap --fstype=swap --ondisk=$install_dev --size=$swap_size --asprimary
#autopart
# System bootloader configuration
bootloader --append="rhgb quiet crashkernel=128M 16M console=tty1
console=ttyS0,38400n8" --location=mbr --driveorder=$install_dev

EOF

%post
#update dns and nameservers
cat >/etc/resolv.conf<<EOF
search mydns.com
nameserver 5.5.3.240
nameserver 5.5.64.127
EOF

cat >/etc/yum.repos.d/packages.repo<<EOF
[packages]
name=local packages
baseurl=http://area51/packages
enabled=1
gpgcheck=0
EOF

cat >/etc/yum.repos.d/rhel5_local.repo<<EOF
[rhel5]
name=Red Hat Enterprise Linux 5 local - \$basearch
baseurl=http://area51/repo/RHEL5/\$basearch
enabled=1
gpgcheck=0
EOF
chkconfig httpd on
# modify grub for serial console
sed -i -e 's/^timeout=5/serial --unit=0 --speed=38400 --word=8
--parity=no --stop=1 \
terminal --timeout=5 serial console \
timeout=5/' /boot/grub/grub.conf

# modify inittab to add serial console login
cat >>/etc/inittab <<EOF

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
HOSTIP=$(ifconfig eth0 | grep "inet addr" | cut -d: -f2|awk '{print $1}')
NETMASK=$(ifconfig eth0 | grep Mask | cut -d: -f4)
HOSTNAME=$(host $HOSTIP 5.5.64.127 | grep pointer | cut -d' ' -f 5 |
cut -d. -f1 )
#FQDN=$(host $HOSTNAME 5.5.64.127 | grep address | cut -d' ' -f1)
if [ -z "$HOSTIP" ] ; then
	echo "Did not find a IP address for host $HOSTNAME from Server:$DNS!"
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
HOSTNUM=$[ $(echo $HOSTNAME |  perl -ln -e '/([1-9]+)$/; print "$1";') % 255]
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

%include /tmp/part-include