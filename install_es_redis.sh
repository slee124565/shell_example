#!/bin/bash -x 
  
export LC_ALL=C

source ./util.sh

check_java8() {
	[ -z $(which java) ] && exit 0
	
    if [ -z $(java -version | grep "1.8") ];then
        echo "java 8 is already exist, skip java 8 install process"
    fi
}

install_java_8() {

    # check java 8 exist
    [ ! -z "$(check_java8)" ] && return 0

    echo "start install oracle-java8 ..." 
	sudo add-apt-repository -y ppa:webupd8team/java
	sudo apt-get update
	sudo apt-get -yq install oracle-java8-installer
	check_err "install java 8 fail!"
	echo "finish install oracle-java8" 
}

install_elasticsearch() {
	
	# check es exist
    [ $(check_service_exist elasticsearch) -eq 1 ] && echo 'es already exist, skip.' && return 0	

    sudo mkdir -p ~/es
	cd ~/es
	
	# download es 2.3.3 package
	sudo wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-2.3.3.deb
	check_err "download es 2.3.3 package fail"
	
	# deploy es package
	sudo dpkg -i elasticsearch-2.3.3.deb
	check_err "deploy elasticsearch package fail"
	
	# config es as daemon service
	sudo update-rc.d elasticsearch defaults
	check_err "config es as daemon service fail"
	
	# start elasticsearch
	sudo service elasticsearch restart
	check_err "start elasticsearch fail"
}

install_es_plugin_head() {
    
    # check plugin exist
    [ -d /usr/share/elasticsearch/plugins/head ] && echo 'es plugin head already exist, skip.' && return 0
    
	# install es plugin head
	cd /usr/share/elasticsearch/bin
	./plugin install mobz/elasticsearch-head
	check_err "install es plugin head fail"
    cd -
}

install_es_plugin_ik() {

    # check plugin exist
    [ -d /usr/share/elasticsearch/plugins/ik ] && echo 'es plugin head already exist, skip.' && return 0

	mkdir -p ~/es
	cd ~/es
	
	# download es plugin ik
	wget https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v1.9.3/elasticsearch-analysis-ik-1.9.3.zip
	check_err "download es plugin ik fail"
	
	# deploy es plugin ik
	unzip elasticsearch-analysis-ik-1.9.3.zip -d /usr/share/elasticsearch/plugins/ik
	check_err "deploy es plugin ik fail"
	
    cd -
}

config_es_server() {

    ES_CONFIG_DEFAULT=/etc/elasticsearch/elasticsearch.default
	ES_CONFIG_FILE=/etc/elasticsearch/elasticsearch.yml
    ES_DATA_PATH=/home/elasticsearch/datas
    ES_LOG_PATH=/home/elasticsearch/logs

    # backup default elasticsearch.yaml to elasticsearch.default
    if [ ! -f "${ES_CONFIG_DEFAULT}" ]; then
        cp ${ES_CONFIG_FILE} ${ES_CONFIG_DEFAULT}
    else
        cp ${ES_CONFIG_DEFAULT} ${ES_CONFIG_FILE}
    fi

    # create elasticsearch home directory
    sudo mkdir -p /home/elasticsearch
    sudo chmod 777 /home/elasticsearch

    # create es path.data and path.log
    sudo mkdir -p ${ES_DATA_PATH}
    check_err "create es path.data fail"
    sudo chmod 777 ${ES_DATA_PATH}

    sudo mkdir -p ${ES_LOG_PATH}
    check_err "create es path.log fail"
    sudo chmod 777 ${ES_LOG_PATH}

	# cluster.name: Viscovery-Service
    sed -i '/cluster.name/ c\cluster.name: Viscovery-Service' ${ES_CONFIG_FILE}
	# node.name: VCMS-Node1
    sed -i '/node.name/ c\node.name: VCMS-Node1' ${ES_CONFIG_FILE}
	# path.data: /volume/elasticsearch/datas
    sed -i '/path.data/ c\path.data: '${ES_DATA_PATH} ${ES_CONFIG_FILE}
	# path.logs: /volume/elasticsearch/logs 
    sed -i '/path.log/ c\path.log: '${ES_LOG_PATH} ${ES_CONFIG_FILE}
	# network.host: 0.0.0.0
    sed -i '/network.host/ c\network.host: 0.0.0.0' ${ES_CONFIG_FILE}
	# append script.inline: on
	echo "script.inline: on" >> ${ES_CONFIG_FILE}
	# append script.indexed: on
	echo "script.indexed: on" >> ${ES_CONFIG_FILE}
	# append marvel.enabled: false
	echo "marvel.enabled: false" >> ${ES_CONFIG_FILE}
	
	sudo service elasticsearch restart	
}

install_redis() {

    # check es exist
    [ $(check_service_exist redis_6379) -eq 1 ] && echo 'redis already exist, skip.' && return 0    

	sudo mkdir -p ~/redis
	cd ~/redis
	
	# download redis package
	sudo wget http://download.redis.io/releases/redis-stable.tar.gz
	check_err "download redis sw package fail"
	
	# make redis from src code
	sudo tar xzf redis-stable.tar.gz
	cd redis-stable
	make
	check_err "make redis fail"
	
	# deploy redis
	sudo make install
	check_err "deploy redis fail"
	
	# install redis server
    ./utils/install_server.sh
	check_err "install redis server fail"
	
	# config redis as daemon
	sudo update-rc.d redis_6379 defaults
	check_err "config redis as daemon fail"
	
	# restart redis
	sudo service redis_6379 restart
}

install_req_lib() {
    sudo apt-get update && sudo apt-get -yq install wget build-essential tcl8.5 tar zip software-properties-common
    check_err "install pre-request lib fail!"
}

install_req_lib
install_java_8
install_elasticsearch
install_es_plugin_head
install_es_plugin_ik
config_es_server
install_redis
