#!/bin/bash -x 
  
export LC_ALL=C
export NGINX_CONFIG_INSTALL_PATH=/etc/nginx/sites-enabled
export UWSGI_CONFIG_INSTALL_PATH=/etc/uwsgi/apps-enabled
export GIT_INCLUDE=1

FILE_PATH=$(echo $(cd $(dirname "$0") && pwd -P)/$(basename "$0"))
BASEDIR=$(dirname "$(dirname "${FILE_PATH}")")
echo "BASEDIR: ${BASEDIR}"
LOG_PATH=$(dirname ${FILE_PATH})/log

source ./util.sh

usage()
{
more <<EOM

Usage:

${0##*/} -s <TARGET_NAME | PACK_NAME> -o <OPTION_CONFIG>

    -s <TARGET_NAME> target_name specify a <system service | app sw package | app config> to be install:
			'python' : install linux system python related tools and librarys
			'db_mq' : install linux system MariaDB and RabbitMQ service
			'nginx' : install linux system Nginx and uWSGI service 
			'es_redis' : install linux system Elasticsearch and Redis service
			'vcms' : install vcms app sw package
			'vcmns_db' : install vcms db instance in db server
			'vcms_es': install vcms_es_server app sw pacakge
			'vds' : install vds app sw package and related daemon config
			'vds_db' : install vds app db instance in db server
			'vds_queue_account' : install mq account used by vds app
			'vds_queue' : install queue used by vds app
			'hrs' : install hrs app sw package
			'hrs_queue' : install queue used by hrs app
			'model' : install model package used by rcnn app
			'rcnn' : install rcnn appp sw package
			'vhost' : install vhost app sw package
			'deploy_key' : install deploy ssh key
			'host_origin_key' : rollback host id_rsa key after install deploy ssh key
		
		<PACK_NAME> : pack_name specify a combination of target_name:
			'allinone' : install all vcms service on single machine host
			'std_app' : install vcms web related service on one machine host
			'std_rcnn' : install vhost & RCNN service on one machine host
	
    -o <SITE_NAME> specify the shell source file under sub-directory <SITE_NAME> to be included during installation
     		'sg' : specify the current config for VCMS SG site
     		'allinone' : speficy a self testing environment

For example

    install all vcms service in single one machine (all in one) :
    ./${0##*/} -s allinone

    install vcms web related service in one machine :
    ./${0##*/} -s std_app -o sg
    
    install RCNN related service in one machine :
    ./${0##*/} -s std_rcnn -o sg

    install vds app sw package  :
    ./${0##*/} -s vds -o test

EOM
}


install_vcms() {
	description='vds_vcms app sw package installation'
	cd vds_vcms
    echo "start ${description} ..."
	./install_vds_vcms.sh -a ${VCMS_ADDR} -t ${VCMS_PORT} -b ${VDS_ADDR} -c ${VDS_PORT} -d ${DB_ADDR} -u ${VCMS_DB_USER} -p ${VCMS_DB_PWD} -i ${VCMS_DB_NAME} -j ${VCMS_PLAYER_JSON} -o ${NFS_FOLDER} > ${LOG_PATH}/install_vcms.log 2>&1 
	check_err "install_vds_vcms fail!"
    echo "${description} complete"
	cd -
}

install_vcms_db() {
	description='vcms db instance creation'
    echo "start ${description} ..."
    ./install_app_db.sh -h ${VCMS_ADDR_LOCAL} -d ${DB_ADDR} -u ${VCMS_DB_USER} -p ${VCMS_DB_PWD} -i ${VCMS_DB_NAME} -f ./vds_vcms/vds_vcms.sql 
	check_err "install_app_db for VCMS fail!"
    echo "${description} complete"

}

install_vcms_es() {
	description='vds_es_server app sw package installation'
	cd vds_es_server
    echo "start ${description} ..."
	./install_vds_es_server.sh -d ${DB_ADDR} -u ${VCMS_DB_USER} -p ${VCMS_DB_PWD} -i ${VCMS_DB_NAME} -e ${EL_URL} > ${LOG_PATH}/install_vcms_es.log 2>&1
	check_err "install_vds_es_server fail!"
    echo "${description} complete"
	cd -
}

install_vds() {
	description='vds_api app sw package installation'
    echo "start ${description} ..."
	cd vds_api
	./install_vds_api.sh -a ${VCMS_ADDR}:${VCMS_PORT} -b ${VDS_ADDR} -c ${VDS_PORT} -d ${DB_ADDR} -u ${VDS_DB_USER} -p ${VDS_DB_PWD}  -i ${VDS_DB_NAME} -r ${MQ_ADDR} -o ${NFS_FOLDER} > ${LOG_PATH}/install_vds.log 2>&1
	check_err "install_vds_api fail!"
	cd -
    echo "${description} complete"
}

install_vds_db() {
	description='vds db instance creation'
    echo "start ${description} ..."
    ./install_app_db.sh -h ${VDS_ADDR_LOCAL} -d ${DB_ADDR} -u ${VDS_DB_USER} -p ${VDS_DB_PWD} -i ${VDS_DB_NAME} -f ./vds_api/vds_api.sql
	check_err "install_app_db for VDS fail!"
    echo "${description} complete"
}

install_vds_queue_account() {
	description='vds mq account creation'
    echo "start ${description} ..."
    ./install_app_queue.sh -r ${MQ_ADDR} -x ${MQ_USER} -y ${MQ_PWD} -z account
	check_err "install_app_queue for account fail!"
    echo "${description} complete"
}

install_vds_queue() {
	description='vds mq queue creation'
    echo "start ${description} ..."
    ./install_app_queue.sh -r ${MQ_ADDR} -x ${MQ_USER} -y ${MQ_PWD} -z VDS
	check_err "install_app_queue for VDS fail!"
    echo "${description} complete"
}

install_hrs() {
	description='vds_hrs app sw package installation'
    echo "start ${description} ..."
	cd vds_hrs
	./install_vds_hrs.sh -b ${VDS_ADDR}:${VDS_PORT} -d ${DB_ADDR} -u ${VDS_DB_USER} -p ${VDS_DB_PWD} -i ${VDS_DB_NAME} -r ${MQ_ADDR} -w ${HRS_WEBSOCKET_IP} -s ${HRS_WEBSOCKET_IP}:${HRS_SCK_SERV_PORT} > ${LOG_PATH}/install_hrs.log 2>&1 
	check_err "install_vds_hrs fail!"
	cd -
    echo "${description} complete"
}

install_hrs_queue() {
	description="hrs mq queue creation"
    echo "start ${description} ..."
    ./install_app_queue.sh -r ${MQ_ADDR} -x ${MQ_USER} -y ${MQ_PWD} -z HRS
	check_err "install_app_queue for HRS fail!"
    echo "${description} complete"
}

install_rcnn() {
	description="orbit_si app sw package installation"
    echo "start ${description} ..."
	cd rcnn
	./install_rcnn.sh -f ${RCNN_FACE_PORT} -o ${RCNN_OBJECT_PORT} -c ${RCNN_CAR_PORT} -d ${RCNN_DRINK_PORT} -s ${RCNN_SCENE_PORT} -p ${RCNN_PATCHES_PATH} -m ${RCNN_MODEL_PATH} > ${LOG_PATH}/install_rcnn.log 2>&1
	check_err "install_rcnn fail!"
	cd -
    echo "${description} complete"
}

install_model() {
	description="orbit_si model file package installation"
    echo "start ${description} ..."
    cd model
    ./install_model.sh -p ${RCNN_MODEL_PATH} -m all -v origin/master > ${LOG_PATH}/install_model.log 2>&1
	check_err "install_model fail!"
	cd -
    echo "${description} complete"
}

install_vhost() {
	description="vhost app sw package installation"
    echo "start ${description} ..."
	cd vhost
	./install_vhost.sh -l ${VHOST_LOCAL_IP} -p ${VHOST_PUBLIC_IP} -m all -a http://${VDS_ADDR}:${VDS_PORT} -u ${NFS_FOLDER} -r 3 > ${LOG_PATH}/install_vhost.log 2>&1
	check_err "install_vhost fail!"
	cd -
    echo "${description} complete"
}

install_db_mq() {
	description="MariaDB and RabbitMQ service installation"
    echo "start ${description} ..."
	./install_db_mq_service.sh # 2>&1> ${LOG_PATH}/install_db_mq.log
	check_err "install_db_mq_service fail!"
    echo "${description} complete"
}

install_nginx() {
	description="nginx and uwsgi server installation"
    echo "start ${description} ..."
	./install_nginx_uwsgi.sh > ${LOG_PATH}/install_nginx.log 2>&1
	check_err "install_nginx_uwsgi fail!"
    echo "${description} complete"
}

install_es_redis() {
	description="Elasticsearch and Redis server installation"
    echo "start ${description} ..."
	./install_es_redis.sh #> ${LOG_PATH}/install_es_redis.log 2>&1
	check_err "install_es_redis fail!"
    echo "${description} complete"
}

install_python(){
	# usage: install_python [std_app|std_vhost|allinone]
	
	description="python related library installation"
    echo "start ${description} ..."
	deploy=$1
	# install require python lib for VCMS, VDS, HRS, vhost
	./install_python_lib.sh ${deploy} > ${LOG_PATH}/install_python.log 2>&1
	check_err "install_python_lib fail!"
    echo "${description} complete"
}

install_package() {
	# usage: install_package [std_app|std_vhost|allinone]
	
	description="all vds related app sw package git clone download"
    echo "start ${description} ..."
	deploy=$1
	./fetch_vds_source.sh -b ${GIT_REF_NAME} -d ${deploy} > ${LOG_PATH}/install_package.log 2>&1
	check_err "fetch_vds_source fail!"
    echo "${description} complete"
}

install_allinone() {
	install_python
	install_package
	install_db_mq
	install_nginx
	install_es_redis
	install_vcms
	install_vcmns_db
	install_vcms_es
	install_vds
	install_vds_db
	install_vds_queue_account
	install_vds_queue
	install_hrs
	install_hrs_queue
	install_model
	install_rcnn
	install_vhost
	
}

install_std_rcnn() {
	install_python std_vhost
	install_package std_vhost
	install_model
	install_rcnn
	install_vhost
}
install_std_app() {
	install_python std_app
	install_package std_app
	install_db_mq
	install_nginx
	install_es_redis
	install_vcms
	install_vcmns_db
	install_vcms_es
	install_vds
	install_vds_db
	install_vds_queue_account
	install_vds_queue
	install_hrs
	install_hrs_queue
}

ip_addr_auto_fill() {
	primary_addr=$(get_local_primary_ip)
	[ -z ${VCMS_ADDR} ] && \
		echo "auto set VCMS_ADDR to local primary address ${primary_addr}" && \
		VCMS_ADDR=${primary_addr}
		
	[ -z ${VDS_ADDR} ] && \
		echo "auto set VCMS_ADDR to local primary address ${primary_addr}" && \
		VDS_ADDR=${primary_addr}

	[ -z ${VHOST_LOCAL_IP} ] && \
		echo "auto set VHOST_LOCAL_IP to local primary address ${primary_addr}" && \
		VHOST_LOCAL_IP=${primary_addr}

	[ -z ${VHOST_PUBLIC_IP} ] && \
		echo "auto set VHOST_PUBLIC_IP to local primary address ${primary_addr}" && \
		VHOST_PUBLIC_IP=${primary_addr}		
}

parse_args() {
    model_list=
    optstring=s:o:
    while getopts $optstring opt
    do
    case $opt in
      s) stage=$OPTARG;;
      o) site_name=$OPTARG;;
      *) usage;
        esac
    done

    # check INSTALL_STAGE
    [ -z "${stage}" ] && echo "No INSTALL_STAGE is specified!" && usage && exit 1

	# check INSTALL_CONFIG
    [ -z "${site_name}" ] && echo "warning: No INSTALL_CONFIG is specified, set to allinone" && site_name=allinone
}

parse_args $@

if [ ${site_name} = "allinone" ]; then
	[ ! -f ./config/config_allinone.sh ] && echo "ERR Param <INSTALL_CONFIG>, file ./config/config_allinone.sh not exist." && exit 2
	source ./config/config_allinone.sh
else
	[ ! -f ./config/${site_name}/config.sh ] && echo "ERR Param <INSTALL_CONFIG>, file ./config/${site_name}/config.sh not exist." && exit 2
	source ./config/${site_name}/config.sh
fi

ip_addr_auto_fill
install_${stage}
