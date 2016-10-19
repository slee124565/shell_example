#!/bin/bash -x
  
export LC_ALL=C

FILE_PATH=$(echo $(cd $(dirname "$0") && pwd -P)/$(basename "$0"))
BASEDIR=$(dirname "$(dirname "${FILE_PATH}")")
echo "BASEDIR: ${BASEDIR}"
VDS_SRC_DIR=${BASEDIR}"/vds_api"
HRS_SRC_DIR=${BASEDIR}"/vds_hrs"
echo "vds_api source path ${VDS_SRC_DIR}"
echo "vds_hrs source path ${HRS_SRC_DIR}"

source ./util.sh

usage()
{
more <<EOM

Usage:

${0##*/} -r <MQ_ADDR> -x <MQ_USER> -y <MQ_PWD> -z <APP_NAME>

    -r <MQ_ADDR> RabbitMQ server internal IP address

    -x <MQ_USER> RabbitMQ login username

    -y <MQ_PWD> RabbitMQ login password
    
    -z <APP_NAME> App Name: VDS | HRS | all | account 


For example
	create MQ account
    ./${0##*/} -r 127.0.0.1 -x xxx -y xxx -z account
	
    install VDS message queue
    ./${0##*/} -r 127.0.0.1 -x xxx -y xxx -z VDS

    install HRS message queue
    ./${0##*/} -r 127.0.0.1 -x xxx -y xxx -z HRS

EOM
}

check_n_create_mq_account() {
	mqctl=$(get_mqctl_exec)
	
	# check if rabbitmqctl command exist
	[ -z ${mqctl} ] && "Err: this function should be executed at MQ server environment!" && exit 1
	
	# check RabbitMQ server status
	${mqctl} status
	check_err "RabbitMQ server status error! Please check it!"
	
	# check username exist
	if [ -z "$(${mqctl} list_users | grep ${mq_user})" ]; then
	    echo "create MQ account ${mq_user} ..."
	    ${mqctl} add_user ${mq_user} ${mq_passwd}
	    check_err "Can not add MQ user ${mq_user}!"
	    
	    echo "set MQ account ${mq_user} permission ..."
	    ${mqctl} set_permissions ${mq_user} ".*" ".*" ".*" 
	    check_err "Can not set MQ user ${mq_user} permission!"
	else
		echo "MQ account ${mq_user} already exsit."
    fi	
}

install_vds_queue() {
	[ ! -d ${VDS_SRC_DIR} ] && echo "Need VDS_API source code at path ${VDS_SRC_DIR}!" && exit 1
	cd ${VDS_SRC_DIR}
	PYTHON_EXE=$(which python)
    export PYTHONPATH=${VDS_SRC_DIR}
	$PYTHON_EXE ./message_queue/create_vds_api_exchange_and_queues.py
	check_err "Can not create VDS_API queue!" 
}

install_hrs_queue() {
	[ ! -d ${HRS_SRC_DIR} ] && echo "Need VDS_HRS source code at path ${HRS_SRC_DIR}!" && exit 1
	cd ${HRS_SRC_DIR}
	PYTHON_EXE=$(which python)
    export PYTHONPATH=${HRS_SRC_DIR}
	$PYTHON_EXE ./websocket/rabbitmq_helper.py
	check_err "Can not create VDS_HRS queue!" 
}

install_app_queue() {
	if [ $1 == "VDS" ]; then
		install_vds_queue
	elif [ $1 == "HRS" ]; then
		install_hrs_queue
	else
		install_vds_queue
		install_hrs_queue
	fi
}

parse_args() {
    model_list=
    optstring=r:x:y:z:
    while getopts $optstring opt
    do
    case $opt in
      r) host_mq=$OPTARG;;
      x) mq_user=$OPTARG;;
      y) mq_passwd=$OPTARG;;
      z) app_name=$OPTARG;;
      *) usage;
        esac
    done

    # check MQ_ADDR
    [ -z "${host_mq}" ] && echo "No MQ_ADDR is specified!" && usage && exit 1

    # check MQ_USER
    [ -z "${mq_user}" ] && echo "No MQ_USER is specified!" && usage && exit 1

    # check MQ_PWD
    [ -z "${mq_passwd}" ] && echo "No MQ_PWD is specified!" && usage && exit 1

    # check APP_NAME
    [ -z "${app_name}" ] && echo "No APP_NAME is specified!" && usage && exit 1
	if [ "${app_name}" != "VDS" ] && [ "${app_name}" != "HRS" ] &&  [ "${app_name}" != "account" ] &&  [ "${app_name}" != "all" ]; then
		echo "APP_NAME ERROR!" && usage && exit 1
    fi
}


parse_args $@

if [ ${app_name} == "account" ]; then
	check_n_create_mq_account
	echo 'check and create MQ account success.'
else
	install_app_queue ${app_name}
	echo "${app_name} app queue installation success."
fi
