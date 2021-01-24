%post
	# yum install -y policycoreutils-python
	echo "admin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/admin
	## Change ssh port:
	# /usr/bin/sed -i "s%#Port 22%Port 43389%g" "/etc/ssh/sshd_config"
	# /usr/bin/sed -i "s%#PermitRootLogin yes%PermitRootLogin no%g" "/etc/ssh/sshd_config"
	# /sbin/semanage port -a -t ssh_port_t -p tcp 22822
	# /usr/bin/firewall-cmd --permanent --zone=public --remove-service=ssh
%post --nochroot
	cp /etc/resolv.conf /mnt/sysimage/etc/resolv.conf

##================================================

## Сценарий: после установки
## У вас есть возможность задать команды, которые будут выполнены сразу после завершения установки. Этот раздел должен располагаться в конце файла kickstart и начинаться с команды %post. Данный раздел полезен для таких операций, как установка дополнительного программного обеспечения и настройка дополнительного сервера имён.
## 	Замечание
## Если вы используете статическую настройку IP, включая сервер имён, в разделе %post вы можете обращаться к сети и разрешать IP-адреса. Если для определения сетевых параметров используется DHCP, файл /etc/resolv.conf не будет создан к моменту, когда программа установки выполняет раздел %post. Вы можете обращаться к сети, но вы не можете разрешать IP-адреса. Таким образом, если вы используете DHCP, в разделе %post вы должны указывать IP-адреса.
## 	Замечание
## Сценарий, запускаемый после установки, работает в окружении chroot; поэтому выполнить некоторые задачи, такие как копирование сценариев или пакетов RPM с установочных носитителей, не удастся.
## --nochroot
## Позволяет вам указать команды, которые вы бы хотели выполнить вне окружения chroot.
## В следующем примере файл /etc/resolv.conf копируется в только что созданную файловую систему.

## --interpreter /usr/bin/python
## Позволяет вам указать другой язык сценариев, например, Python. Замените /usr/bin/python предпочитаемым вами языком сценариев.

## 1.7.1. Примеры
## Включение и выключение служб:
## /sbin/chkconfig --level 345 telnet off
## /sbin/chkconfig --level 345 finger off
## /sbin/chkconfig --level 345 lpd off
## /sbin/chkconfig --level 345 httpd on
## Запуск сценария с именем runme, находящегося в разделяемом NFS-ресурсе:
mkdir /mnt/temp
#mount -o nolock 10.10.0.2:/usr/new-machines /mnt/temp
#open -s -w -- /mnt/temp/runme
#umount /mnt/temp
## 	Замечание
## NFS-блокировка файлов в режиме kickstart неподдерживаетс, поэтому при монтировании NFS-ресурса требуется указать -o nolock.
## Добавление пользователя в систему:
## /usr/sbin/useradd bob
## /usr/bin/chfn -f "Bob Smith" bob
## /usr/sbin/usermod -p 'kjdf$04930FTH/ ' bob
