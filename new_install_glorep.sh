#!/bin/bash

#draw glorep logo
function logoGlorepIntaller {

	clear

	echo "----------------------------------------------------------------------"
 	echo " _____ _                        _____          _        _ _           "
	echo "|  __ \ |                      |_   _|        | |      | | |          "
	echo "| |  \/ | ___  _ __ ___ _ __     | | _ __  ___| |_ __ _| | | ___ _ __ "
	echo "| | __| |/ _ \| '__/ _ \ '_ \    | || '_ \/ __| __/ _' | | |/ _ \ '__|"
	echo "| |_\ \ | (_) | | |  __/ |_) |  _| || | | \__ \ || (_| | | |  __/ |   "
	echo " \____/_|\___/|_|  \___| .__/   \___/_| |_|___/\__\__,_|_|_|\___|_|   "
	echo "	                     | |                                            "
	echo "	                     |_|                                            "
	echo "----------------------------------------------------------------------"
}

#function get password
RETURNPASSWORD=""
function writePassword {

	FIRSTPASS=none
	TOWPASS=nil
	WHILE_LOOP_PASSWORD=1

	while (( WHILE_LOOP_PASSWORD==1 )); do
		#first password
		echo -n "Password: "
		read -s FIRSTPASS
		echo
		#second password
		echo -n "Confirm password: "
		read -s TOWPASS
		echo
		#test password
		if [[ $FIRSTPASS != $TOWPASS ]]; then 
			echo "Password does not match the confirm password"		
		elif [[ $FIRSTPASS == "" ]]; then 
			echo "Password must be length more than 0 characters"
		else
			WHILE_LOOP_PASSWORD=0
		fi
	done

	RETURNPASSWORD=`echo $FIRSTPASS`
		
}

#function get username
RETURNNOZERONAME=""
function writeNoZeroName {

	LOCALRETURNNOZERONAME=""
	WHILE_LOOP_USERNAME=1

	while (( WHILE_LOOP_USERNAME==1 )); do

		read LOCALRETURNNOZERONAME

		if [[ $LOCALRETURNNOZERONAME == "" ]]; then 
			echo "Must be length more than 0 characters"
		else
			WHILE_LOOP_USERNAME=0
		fi
	done

	RETURNNOZERONAME=`echo $LOCALRETURNNOZERONAME`
		
}

#install mysql
MYSQLROOTPASSWORD=""
function intallMysql {


	#mysql is already installed?
	if  [[ "${version=$(isRedHatDistro)}" == "1" && `rpm --query --all | grep -w "mysql-server"` ]] || [[ `dpkg -l | grep -w "mysql-server"` ]]; then
			#insert database password
			echo "get me mysql root password:"
			writePassword
			MYSQLROOTPASSWORD=`echo $RETURNPASSWORD`
			#is not root password
			while ! mysql -uroot -p$MYSQLROOTPASSWORD -e ";" ; do
				#print logo
				logoGlorepIntaller
				#error message
				echo "It isn't mysql root password, please try again"
				writePassword
				MYSQLROOTPASSWORD=`echo $RETURNPASSWORD`
			done
	else 
			echo "mysql not installed"
			echo "start installation mysql..."
			echo "get me mysql root password:"
			writePassword	
			MYSQLROOTPASSWORD=`echo $RETURNPASSWORD`
			#installation mysql
			echo "-----------------------------------------------------------"			
			echo " _____          _        _ _           _                   "
			echo "|_   _|        | |      | | |         (_)                  "
			echo "  | | _ __  ___| |_ __ _| | | __ _ _____  ___  _ __   ___  "
			echo "  | || '_ \/ __| __/ _' | | |/ _' |_  / |/ _ \| '_ \ / _ \ "
			echo " _| || | | \__ \ || (_| | | | (_| |/ /| | (_) | | | |  __/ "
			echo " \___/_| |_|___/\__\__,_|_|_|\__,_/___|_|\___/|_| |_|\___| "
			echo "			                                                 "
			echo "			                                                 "
			echo "			  ___  ___      _____  _____ _                   "
			echo "			  |  \/  |     /  ___||  _  | |                  "
			echo "			  | .  . |_   _\ '--. | | | | |                  "
			echo "			  | |\/| | | | |'--. \| | | | |                  "
			echo "			  | |  | | |_| /\__/ /\ \/' / |____              "
			echo "			  \_|  |_/\__, \____/  \_/\_\_____/              "
			echo "			           __/ |                                 "
			echo "	  		          |___/                                  "
			echo "-----------------------------------------------------------"
			echo -n "3 "
			sleep 1
			echo -n "2 "
			sleep 1
			echo -n "1 "
			sleep 1
			#installation mysql
			debconf-set-selections <<< `echo "mysql-server mysql-server/root_password password $MYSQLROOTPASSWORD"`
			debconf-set-selections <<< `echo "mysql-server mysql-server/root_password_again password $MYSQLROOTPASSWORD"`
			if [ "${version=$(isRedHatDistro)}" == "1" ]; then
				yum install mysql-server mysql-client
			else
				apt-get -y install mysql-server mysql-client
			fi
	fi

}

function intallApache2 {

	if [[ "${version=$(isRedHatDistro)}" == "1" &&`rpm --query --all | grep -w "apache2"` ]] || [[ `dpkg -l | grep -w "apache2"` ]]; then
		echo "apache2 is already installed"
		sleep 2
	else
		echo ""
		echo "...................................."
		echo "                                __  "
		echo " __   __   __   __  |__   ___   __) "
		echo "(__( |__) (__( (___ |  ) (__/_ (___ "
		echo "     |                              "
		echo "...................................."
		echo ""
		#my sql dipedences
		if [ "${version=$(isRedHatDistro)}" == "1" ]; then
			yum install httpd
		else
			apt-get -y install apache2
		fi
	fi

}

function dipedencesOlreadyInstalled {

# What dependencies are missing?
PKGSTOINSTALL=""
for (( i=0; i<${tLen=${#DEPENDENCIES[@]}}; i++ )); do
	# Debian, Ubuntu and derivatives (with dpkg)
	if which dpkg &> /dev/null; then
		if [[ ! `dpkg -l | grep -w "ii  ${DEPENDENCIES[$i]} "` ]]; then
			PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
		fi
	# OpenSuse, Mandriva, Fedora, CentOs, ecc. (with rpm)
	elif which rpm &> /dev/null; then
		if [[ ! `rpm -q ${DEPENDENCIES[$i]}` ]]; then
			PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
		fi
	# ArchLinux (with pacman)
	elif which pacman &> /dev/null; then
		if [[ ! `pacman -Qqe | grep "${DEPENDENCIES[$i]}"` ]]; then
			PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
		fi
	# If it's impossible to determine if there are missing dependencies, mark all as missing
	else
		PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
	fi
done

}

function installPhp5 {

	#all php5 dip installed?
	PKGSTOINSTALL=""
	DEPENDENCIES=""
	DEPENDENCIES=(php5 libapache2-mod-php5 php5-mysql php5-curl php5-gd)
	dipedencesOlreadyInstalled

	if [ "$PKGSTOINSTALL" != "" ]; then	

		echo ""
		echo "...................."
 		echo "                __  "
		echo " __  |__   __  (__  "
		echo "|__) |  ) |__) ___) "
		echo "|         |         "
		echo "...................."
		echo ""
		#php5 dipedences
		if [ "${version=$(isRedHatDistro)}" == "1" ]; then
			yum install $PKGSTOINSTALL
		else
			apt-get -y install $PKGSTOINSTALL
		fi

	else
		echo "php5 is already installed"
		sleep 2		
	fi

}

function installPython {

	#all python dip installed?
	PKGSTOINSTALL=""
	DEPENDENCIES=""
	DEPENDENCIES=(libmysqlclient-dev python2.7-dev python-mysqldb)
	dipedencesOlreadyInstalled

	if [ "$PKGSTOINSTALL" != "" ]; then	
		echo ""
		echo ".............................."                              
		echo " __       _|_  |__   __   __  "
		echo "|__) (__|  |_, |  ) (__) |  ) "
		echo "|       |                     "
		echo ".............................."
		echo ""
		#python dipedences
		if [ "${version=$(isRedHatDistro)}" == "1" ]; then
			yum install $PKGSTOINSTALL
		else
			apt-get -y install $PKGSTOINSTALL
		fi

	else
		echo "python is already installed"
		sleep 2		
	fi

}

function installTransmissionDemon {

	#all transmission-daemon dip installed?
	PKGSTOINSTALL=""
	DEPENDENCIES=""
	DEPENDENCIES=(transmission-daemon)
	dipedencesOlreadyInstalled

	if [ "$PKGSTOINSTALL" != "" ]; then	
		echo ""
		echo "........................................................."
		echo "                                                         "
		echo "_|_   __   __   __    __  __ __  o   __   __ o  __   __  "
		echo " |_, |  ' (__( |  ) __)  |  )  ) | __)  __)  | (__) |  ) "
		echo "                                                         "
		echo "........................................................."
		echo ""
		#transmission-daemon dipedences
		if [ "${version=$(isRedHatDistro)}" == "1" ]; then
			yum install $PKGSTOINSTALL
		else
			apt-get -y install $PKGSTOINSTALL
		fi
		#copy modified settings.json
		echo "copy modified setting.json"
		/etc/init.d/transmission-daemon stop
		cp -R settings.json /var/lib/transmission-daemon/info/settings.json
		/etc/init.d/transmission-daemon start
		chmod 777 /var/www/glorep/sites/default/files 
		cp -R /var/www/glorep/sites/default/default.settings.php /var/www/glorep/sites/default/settings.php
		chmod 777 /var/www/glorep/sites/default/settings.php
		chmod 777 /var/www/glorep/sites/default/files/collabrep
		mkdir /var/www/glorep/sites/default/files/collabrep/cache
		chmod 777 /var/www/glorep/sites/default/files/collabrep/cache
	else
		echo "python is already installed"
		sleep 2		
	fi

}

function rightVersionInstalled {
	
	#check if the installed version is the one required
	STRING="$(cat /etc/issue)"

	UBUNTU=${STRING#* }
	TMP=${UBUNTU% *}
	TMP1=${TMP% *}
	VERS=${TMP1#\n*}

	if [ "$VERS" == "12.04.3 LTS" ]; then
		echo 1
	else
		echo 0
	fi
}

function isRedHatDistro {
	
	if [ -e "/cat/redhat-release" ]; then
		echo 1
	else 
		echo 0
	fi
}

if [ `id -u` -eq 0 ]; then
	
	#print logo
	logoGlorepIntaller

	#install mysql
	intallMysql

	#reprint logo
	logoGlorepIntaller


	#database glorep
	echo "get me a database name (name suggested: glorep): "
	writeNoZeroName
	DBNAME=`echo $RETURNNOZERONAME`

	#reprint logo
	logoGlorepIntaller
	#user glorep mysql
	echo "get me the new mysql user:"
	writeNoZeroName
	DBUSER=`echo $RETURNNOZERONAME`

	#reprint logo
	logoGlorepIntaller
	#insert database password
	echo "get me the new mysql user's password:"
	writePassword
	DBPASSWORD=`echo $RETURNPASSWORD`

	#reprint logo
	logoGlorepIntaller

	echo -n "install glorep database 3 "
	sleep 1
	echo -n "2 "
	sleep 1
	echo -n "1 "
	sleep 1
	#write mysql script
	SCRIPT0=`echo '*.*'`
	SCRIPT1=";"
	SCRIPT2="CREATE DATABASE IF NOT EXISTS $DBNAME;"
	SCRIPT3="GRANT USAGE ON $SCRIPT0 TO $DBUSER@localhost IDENTIFIED BY '$DBPASSWORD';"
	SCRIPT4="GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, LOCK TABLES, CREATE TEMPORARY TABLES ON ${DBNAME}.* TO ${DBUSER}@localhost;"
	SCRIPT5="FLUSH PRIVILEGES;"
	SCRIPT_USER_DB="${SCRIPT1}${SCRIPT2}${SCRIPT3}${SCRIPT4}${SCRIPT5}"
	#execute script
	mysql -uroot -p$MYSQLROOTPASSWORD -e "$SCRIPT_USER_DB"
	#install glorep database
	echo "CREATE GLOREP'S TABLES IN GLOREP DATABASE..."
	mysql -u$DBUSER -p$DBPASSWORD  $DBNAME < glorep.sql
	#reprint logo
	logoGlorepIntaller
	echo "glorep database is installed, now will be installed the glorep site"
	sleep 2
	#Apache2 dip
	intallApache2
	#php5 dip
	installPhp5
	#Python dip
	installPython
	#TransmissionDemon
	installTransmissionDemon

	#restart apache
	logoGlorepIntaller
	echo "restart Apache2"
	if [ "${version=$(isRedHatDistro)}" == "1" ]; then
		systemctl restart httpd.service
	else
		/etc/init.d/apache2 restart
	fi
	
	sleep 2

	#and install glorep
	logoGlorepIntaller
	echo "install glorep site..."
	cp -R glorep/ /var/www/
	sleep 1

	echo "set files permission..."
	chmod -R 777 /var/www/glorep/modules/collabrep
	chmod 777 /var/www/glorep/sites/default/files/
	chmod -R 777 /var/www/glorep/sites/default/files/collabrep
	chmod 777 /var/www/glorep/sites/default/files/collabrep/torrent
	chmod 666 /var/www/glorep/modules/collabrep/python/tmp/log.txt
	chmod 666 /var/www/glorep/modules/collabrep/python/transmission/transmissionlog.txt	
	chmod 666 /var/www/glorep/modules/collabrep/python/transmission/listatorrent
	chmod -R 777 /var/www/glorep/modules
	sleep 2

	#and install glorep
	logoGlorepIntaller
	echo "CONFIGURATION DONE! :D"
	echo "Now you can access to site in your prefered webbrowser (http://<public ip>/glorep)" 
	echo "Access with drupal administrator account (user: glorep, password: glorep)" 
	echo "and set the password, user and database create in this installation" 
	
else
	echo "must to be run with root permission"
	exit 1
fi

