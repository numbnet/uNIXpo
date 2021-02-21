##############################################
##~~~~~~~~~~~~~~  ЭТАП 1  ~~~~~~~~~~~~~~~~~~##
##~~~~~~~~~Установка FTP-сервера~~~~~~~~~~~~##
##############################################

####Устанавливаем софт:

	yum install vsftpd nano net-tools -y
#Создаем директорию, где будут каталоги пользователей и выставляем права доступа

	mkdir /home/vsftpd
	chmod 0777 /home/vsftpd
#Cохраняем дефолтный конфиг

	mv /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.backup
	
###################################################################
##						  Пишем свой конфиг 					 ##
###################################################################
touch /etc/vsftpd/vsftpd.conf
echo '
#~nano /etc/vsftpd/vsftpd.conf~~~~~~~~#
#~~~~~~~~~~~~~START~~~~~~~~~~~~~~~~~~~#
# Запуск сервера в режиме службы
listen=YES

# Работа в фоновом режиме
background=YES

# Имя pam сервиса для vsftpd
pam_service_name=vsftpd

# Входящие соединения контроллируются через tcp_wrappers
tcp_wrappers=YES

# Запрещает подключение анонимных пользователей
anonymous_enable=NO

# Каталог, куда будут попадать анонимные пользователи, если они разрешены
#anon_root=/ftp

# Разрешает вход для локальных пользователей
local_enable=YES

# Разрешены команды на запись и изменение
write_enable=YES

# Указывает исходящим с сервера соединениям использовать 20-й порт
connect_from_port_20=YES

# Логирование всех действий на сервере
xferlog_enable=YES

# Путь к лог-файлу
xferlog_file=/var/log/vsftpd.log

# Включение специальных ftp команд, некоторые клиенты без этого могут зависать
async_abor_enable=YES

# Локальные пользователи по-умолчанию не могут выходить за пределы своего домашнего каталога
chroot_local_user=YES

# Разрешить список пользователей, которые могут выходить за пределы домашнего каталога
chroot_list_enable=YES

# Список пользователей, которым разрешен выход из домашнего каталога
chroot_list_file=/etc/vsftpd/chroot_list

# Разрешить запись в корень chroot каталога пользователя
allow_writeable_chroot=YES

# Контроль доступа к серверу через отдельный список пользователей
userlist_enable=YES

# Файл со списками разрешенных к подключению пользователей
userlist_file=/etc/vsftpd/user_list

# Пользователь будет отклонен, если его нет в user_list
userlist_deny=NO

# Директория с настройками пользователей
user_config_dir=/etc/vsftpd/users

# Показывать файлы, начинающиеся с точки
force_dot_files=YES

# Маска прав доступа к создаваемым файлам
local_umask=022

## Порты для пассивного режима работы
pasv_min_port=49000
pasv_max_port=55000

#~~~~~~~~~~~~~END~~~~~~~~~~~~~~~#' >> /etc/vsftpd/vsftpd.conf

# ================== END ================== #

######################################
##		 Добавляем пользователя			
######################################

	useradd -s /sbin/nologin ftpuser
	passwd ftpuser
	1111
#Создаем папку, где будут отдельные конфиги пользователей

	mkdir /etc/vsftpd/users
	touch /etc/vsftpd/users/ftpuser
#Задаем в конфиге домашний ftp-каталог

	echo 'local_root=/home/ftpd/ftpuser/' >> /etc/vsftpd/users/ftpuser
#Cоздаем каталог пользователя и задаем владельца

	mkdir /home/ftpd/ftpuser
	chown ftpuser:ftpuser /home/ftpd/ftpuser
#Создаем файл, в котором будет перечислен список пользователей, которым разрешен выход из домашнего каталога. И добавляем в него пользователя root

	touch /etc/vsftpd/chroot_list
	echo 'root' >> /etc/vsftpd/chroot_list
#Создаем файл, в котором будет перечислен список пользователей,  которым разрешено подключаться к FTP-серверу. Добавляем в него пользователей root и ftpuser

	touch /etc/vsftpd/user_list
	echo 'root' >> /etc/vsftpd/user_list && echo 'ftpuser' >> /etc/vsftpd/user_list
#Создаем файл, куда будут писаться логи, и выставляем на него права

	touch /var/log/vsftpd.log && chmod 600 /var/log/vsftpd.log
#Добавляем сервис vsftpd в автозагрузку, запускаем его, проверяем статус

	systemctl enable vsftpd
	systemctl start vsftpd
	systemctl status vsftpd
#Смотрим, появился ли процесс
	netstat -tulnp | grep vsftpd
#
#->	tcp 0 0 0.0.0.0:21 0.0.0.0:* LISTEN 13195/vsftpd
#
#Добавляем правила в firewall: открываем порты 21, 49000-55000

	firewall-cmd --permanent --add-port=21/tcp
	firewall-cmd --permanent --add-port=49000-55000/tcp
	firewall-cmd --reload
	
#Отключаем Selinux, перезагружаемся
		setenforce 0
		nano /etc/selinux/config
		echo 'SELINUX=disabled' >> /etc/selinux/config
		# reboot

####################################################
##~~~~~~~~~~~~~~~~~~  ЭТАП 2  ~~~~~~~~~~~~~~~~~~~~##
##~~Инструкция по добавлению новых пользователей~~##
#####################################################

#--> Инструкция по добавлению новых пользователей
#--> Добавляем пользователя в систему
#
#	useradd -s /sbin/nologin testuser
#	passwd testuser
#	testuser
#--> Создаем каталог пользователя и задаем владельца
#
#	mkdir /home/ftpd/testuser
#	chown test:test /home/ftpd/testuser

#--> Создаем папку, где будут отдельные конфиги пользователей
#
#	touch /etc/vsftpd/users/testuser
#--> Задаем в конфиге домашний фтп-каталог
#
#	echo 'local_root=/home/ftpd/testuser/' >> /etc/vsftpd/users/testuser
#--> Задаем разрешенных пользователей
#
#	echo 'testuser' >> /etc/vsftpd/user_list
#--> Перезапускаем vsftpd

systemctl restart vsftpd
#->
#->		UPD 27.11.2018
#->

###################################################
###		Bash-скрипт добавления пользователей
###		Создаем bash-скрипт add_ftp_user.sh

#################
## nano /home/add_ftp_user.sh
#################

touch /home/add_ftp_user.sh
echo '#!/bin/bash /home/add_ftp_user.sh

NAME=$1
PASS=$2

echo "Ввведите имя пользователя: "
read NAME

echo "Пароль Пользователя : "
read PASS

echo "USAGE: add_ftp_user.sh [username] [password]"

# проверка входных параметров
if [ -z "$NAME" ]; then
    echo "Error: username is not set"
    exit
fi

if [ -z "$PASS" ]; then
    echo "Error: password not set"
    exit
fi

# создаем системных пользователей
echo "Creating user: $NAME"
echo "With password: $PASS"

useradd -s /sbin/nologin -p `openssl passwd -1 $PASS` $NAME

# сохраняем данные в файл /etc/vsftpd/new_ftp_users_list
echo "user: $NAME, pass: $PASS" >> /etc/vsftpd/new_ftp_users_list

# создаем ftp-директорию пользователя
mkdir /home/ftpd/$NAME

# назначаем владельца
chown $NAME:$NAME /home/ftpd/$NAME

# создаем пустой конфигурационный файл
touch /etc/vsftpd/users/$NAME

# прописываем домашний каталог
echo "local_root=/home/ftpd/$NAME/" >> /etc/vsftpd/users/$NAME

# добавляем пользователя в список разрешенных для подключения
echo "$NAME" >> /etc/vsftpd/user_list

# задаем права каталога пользователя
chmod 0777 /home/ftpd/$NAME

# перезапускаем службу vsftp
systemctl restart vsftpd
#' >> /home/add_ftp_user.sh

#########################################
#######===Делаем его исполняемым===#######

	chmod +x /home/add_ftp_user.sh 
#теперь, что бы добавить нового FTP-пользователя надо выполнить команду

	cd /home
	./add_ftp_user.sh %user% %pass%
#где
#->			%user% — логин
#->			%pass% — пароль

#->		UPD 03.09.2019 — не работает авторизация, ошибка 530
# Не работает авторизация в vsftpd:

#->		530 Login incorrect
####	Решение:

##Данная ошибка получается из-за того, что в файле /etc/pam.d/vsftpd присутствует строчка:

#->			egrep -v "^#|^$" /etc/pam.d/vsftpd
#->		...
#->		 auth       required     pam_shells.so
#->		...

#она означает, что только пользователям с доступом к оболочкам должен быть разрешен доступ
#А добавляли мы пользователя как раз с параметром: -s /sbin/nologin
#
#->		useradd -s /sbin/nologin ftpuser
#
#Комментирует эту строчку: auth required pam_shells.so и перезапускаем vsftpd
#
	systemctl restart vsftpd
#
#######--END--###########