#!/bin/bash -x
  
export LC_ALL=C

source ./util.sh

install_mariadb() {
	# check MariaDB service
	if [ $(check_service_exist mysql) -eq 1 ]; then
		echo "Warning: MariaDB service already exist!"
		return
	fi
	
	# install tool
	#sudo apt-get -y install software-properties-common
	#check_err "install software-properties-common fail"
	
	# import mariadb key
	#sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
	#check_err "import mariadb key fail"
	
	# add mariadb repository
	#sudo add-apt-repository 'deb http://mirror.jmu.edu/pub/mariadb/repo/5.5/ubuntu trusty main'
    #check_err "iadd mariadb repository fail"
	
	# install mariadb
	sudo apt-get -yq install mariadb-server
	check_err "install mariadb fail"
	
	# config mariadb database directory
	sudo service mysql stop
	sudo mysql_install_db
	check_err "config mariadb database directory fail"
	
	# secure mariadb
	sudo service mysql start
	sudo mysql_secure_installation
	check_err "secure mariadb fail"
	
	# config bind-address on my.cnf
	#vim /etc/mysql/my.cnf
}

config_mariadb() {

    # backup/restore my.cnf
    DB_CONFIG_FILE=/etc/mysql/my.cnf
    DB_CONFIG_DEFAULT=/etc/mysql/my.cnf.default
    if [ ! -f ${DB_CONFIG_DEFAULT} ]; then
        cp ${DB_CONFIG_FILE} ${DB_CONFIG_DEFAULT}
    else
        cp ${DB_CONFIG_DEFAULT} ${DB_CONFIG_FILE}
    fi

    # bind-address       = 127.0.0.1
    if [ -z ${DB_BIND_ADDR} ]; then
        sed -i '/bind-address/ c\#bind-address\t= 127.0.0.1' ${DB_CONFIG_FILE}
    else
        sed -i '/bind-address/ c\bind-address\t= '${DB_BIND_ADDR} ${DB_CONFIG_FILE}
    fi
    check_err "config bind-address fail"

    # set wait_timeout        = 28800
    if [ ! -z $(sed -n '/wait_timeout/ =' ${DB_CONFIG_FILE}) ]; then
        sed -i '/wait_timeout/ c\wait_timeout = 28800' ${DB_CONFIG_FILE}
    else
        num=$(sed -n '/max_allowed_packet/ =' ${DB_CONFIG_FILE}|head -1)
        sed -i "${num}i\\wait_timeout = 28800" ${DB_CONFIG_FILE}
    fi
    check_err "config wait_timeout fail"

    # set max_allowed_packet    = 32M
    sed -i '/max_allowed_packet/ c\max_allowed_packet = 32M' ${DB_CONFIG_FILE}
    check_err "config max_allowed_packet fail"

    # mariadb reload
    sudo service mysql restart
    check_err "mariadb restart fail"
}

install_rabbitmq() {

    # check rabbitmq-server service
    if [ $(check_service_exist rabbitmq-server) -eq 1 ]; then
        echo "Warning: MariaDB service already exist!"
        return
    fi

	# add rabbitmq repository
	echo 'deb http://www.rabbitmq.com/debian/ testing main' | sudo tee /etc/apt/sources.list.d/rabbitmq.list
	check_err "add rabbitmq repository fail"
	
	# add rabbitmq key
	wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
	check_err "add rabbitmq key fail"
	
	# install rabbitmq-server
	sudo apt-get -yq install rabbitmq-server
	check_err "install rabbitmq-server fail"
	
	# start rabbitmq-server
	sudo service rabbitmq-server start
	check_err "rabbitmq-server start fail"
	echo "RabbitMQ server install and start"
}

sudo apt-get update
[ -z $(which wget) ] && sudo apt-get -yq install wget

install_mariadb
config_mariadb
install_rabbitmq
