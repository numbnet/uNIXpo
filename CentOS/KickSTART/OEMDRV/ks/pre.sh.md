
######       %pre.sh       ######

## 1.6. Сценарий, выполняемый до установки
## Вы можете добавить команды, которые будут выполнены в системе сразу после
# обработки файла ks.cfg. Этот раздел должен располагаться в конце файла
# kickstart(после команд) и должен начинаться с команды %pre.
# В разделе %pre вы можете обращаться к сети однако, на этом этапе служба
# разрешения имён ещё не настроена, поэтому будут работать только IP-адреса.

#===			ВНИМАНИЕ			===#
# Gред-установочный сценарий не выполняется в окружении chroot.
#======================================#


# ЯЗЫК СЦЕНАРИЕВ [python]
<pre><code> 
%pre --interpreter /usr/bin/python

</code></pre>

#===			EXAMPLE				===#
## Ниже приведён пример раздела '%pre'
<pre><code>
%pre
#!/bin/sh

hds=""
mymedia=""
for file in /proc/ide/h*
do
  mymedia=`cat $file/media`
  if [ $mymedia == "disk" ] ; then hds="$hds `basename $file`"; fi
done
set $hds
numhd=`echo $#`
drive1=`echo $hds | cut -d' ' -f1`
drive2=`echo $hds | cut -d' ' -f2`

# Write out partition scheme based on whether there are 1 or 2 hard drives
if [ $numhd == "2" ] ; then
  #2 drives
  echo "# FOR 2 DRIVES PARTITIONING SCHEME GENERATED IN %PRE" > /tmp/part-include
  echo "clearpart --all" >> /tmp/part-include
  echo "part /boot --fstype ext3 --size 75 --ondisk hda" >> /tmp/part-include
  echo "part / --fstype ext3 --size 1 --grow --ondisk hda" >> /tmp/part-include
  echo "part swap --recommended --ondisk $drive1" >> /tmp/part-include
  echo "part /home --fstype ext3 --size 1 --grow --ondisk hdb" >> /tmp/part-include
else
  #1 drive
  echo "# FOR 1 DRIVE PARTITIONING SCHEME GENERATED IN %PRE" > /tmp/part-include
  echo "clearpart --all" >> /tmp/part-include
  echo "part /boot --fstype ext3 --size 75" >> /tmp/part-includ
  echo "part swap --recommended" >> /tmp/part-include
  echo "part / --fstype ext3 --size 2048" >> /tmp/part-include
  echo "part /home --fstype ext3 --size 2048 --grow" >> /tmp/part-include
fi
%end
%include /tmp/part-include
</code></pre>

#===			INFO				===#
# Этот сценарий определяет количество жёстких дисков в компьютере и сохраняет текстовый файл
# с другой схемой разбиения, если установлены один или два диска.
# Вместо того, чтобы вставлять набор команд разбиения в файл kickstart, добавьте строку:
#======================================#

</code></pre>

%include /tmp/part-include

</code></pre>

#При этом выполняться команды разбиения, указанные в сценарии.

#===			ЗАМЕЧАНИЕ			===#
# В разделе сценариев kickstart, вып. до установки, нельзя управлять
# множеством деревом установочных каталогов или исходным носителем.
# Эту информация должна включаться в каждый создаваемый файл ks.cfg,
# так как эти сценарии выполняются на втором этапе процесса установки.
#======================================#
