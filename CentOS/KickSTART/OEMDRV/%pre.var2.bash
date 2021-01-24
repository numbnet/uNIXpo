%pre
#!/bin/sh

hds="" 
mymedia=""  
for file in /proc/ide/h* do   
	mymedia=`cat $file/media`   
	if [ $mymedia == "disk" ] ; then       
		hds="$hds `basename $file`"   
	fi 
done
set $hds 
numhd=`echo $#`  
drive1=`echo $hds | cut -d' ' -f1` 
drive2=`echo $hds | cut -d' ' -f2`  
#Write out partition scheme based on whether there are 1 or 2 hard drives  
if [ $numhd == "2" ] ; then
	#======partitioning %pre for 2 drives ==========#
cat > /tmp/part-include <<END
clearpart --all
part biosboot --fstype=biosboot --size=2 --ondisk=sda
part /boot --fstype=ext4 --size=1022 --label=BOOT --ondisk=sda
part swap --fstype=swap --size=8196 --ondisk=sda
part / --fstype=ext4 --size=111700 --grow --ondisk=sda
part /home --fstype=ext4 --size=184320 --grow --ondisk=sdg

END
	else
#======partitioning %pre for 1 drives ==========#
cat > /tmp/part-include <<END
clearpart --all
part biosboot --fstype=biosboot --size=2 --ondisk=sda
part /boot --fstype=ext4 --size=1022 --ondisk=sda
part swap --fstype=swap --size=8196
part /  --fstype=xfs --size=111700 --label=ROOT --grow
part /home  --fstype=xfs --size=184320 --label=HOME --grow

END
fi
