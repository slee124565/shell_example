#!/bin/bash

export LC_ALL=C
INSTALL_PATH=/usr/share/vds/vds_hrs
SERVICE_LOG_PATH=/var/log/hrs_log
HRS_DAEMON_FILE=/etc/init.d/vds_hrs

FILE_PATH=$(echo $(cd $(dirname "$0") && pwd -P)/$(basename "$0"))
BASEDIR=$(dirname "$(dirname "$(dirname "${FILE_PATH}")")")
echo "BASEDIR: ${BASEDIR}"
SRC_DIR=${BASEDIR}"/vds_hrs"
echo "vds_hrs source path ${SRC_DIR}"

source ../util.sh

usage()
{
more <<EOM

Usage:

${0##*/} -b <VDS_ADDR> -d <DB_ADDR> -u <DB_USER> -p <DB_PWD> -i <DB_NAME> -r <MQ_ADDR> -w <WEBSOCKET_IP> -s <HRS_WEB_ADDRESS_PORT>

    -b <VDS_ADDR> VDS web domain name or IP address

    -d <DB_ADDR> database server internal IP address

    -u <DB_USER> database login username for HRS

    -p <DB_PWD> database login password for HRS

    -i <DB_NAME> database instance name for VDS_API

    -r <MQ_ADDR> RabbitMQ server IP address

    -w <WEBSOCKET_IP> HRS WebSocket server IP address

    -s <HRS_WEB_ADDRESS_PORT> HRS Web Sever IP:PORT 


For example

    ./${0##*/} -b vds-api2.xxx.co -d 172.17.0.8 -u vds_api -p vds_api -i vds_api -r 172.17.0.8 -w 161.202.164.124 -s 161.202.164.124:8081

EOM
}

config_package() {

    # remove existing change in source if .git control
    [ -d "${SRC_DIR}/.git" ] && cd ${SRC_DIR} && git checkout -f && cd -

	# change param in VDS_API module_config.py file
	config_file=${SRC_DIR}"/config.py"
	
	[ ! -f ${config_file} ] && echo "VDS_API config file ${config_file} not exist!" && exit 1

	echo "" >> ${config_file}

	# VDS_API_ADDRESS = "vds-api.xxx.cn"
	echo "VDS_API_ADDRESS = \"${host_vds}\"" >> ${config_file}

	# VCMS_DB_HOST_IP = "172.16.0.102"
	echo "VCMS_DB_HOST_IP = \"${host_db}\"" >> ${config_file}

	# RABBITMQ_IP = "172.17.0.4"
	echo "RABBITMQ_IP = \"${host_mq}\"" >> ${config_file}

	# VCMS_DB_USERNAME = "xxx"
	echo "VCMS_DB_USERNAME = \"${db_user}\"" >> ${config_file}

	# VCMS_DB_PASS_WORD = "xxx1qaz2wsx"
	echo "VCMS_DB_PASS_WORD = \"${db_passwd}\"" >> ${config_file}

	# VCMS_DB_NAME = "vds_api"
	echo "VCMS_DB_NAME = \"${db_name}\"" >> ${config_file}

	# HRS_IMG_ADDRESS_DEFAULT = VDS_API_ADDRESS
	echo "HRS_IMG_ADDRESS_DEFAULT = VDS_API_ADDRESS" >> ${config_file}

	# HRS_IMG_ADDRESS_CANDIDATE_HK = "119.81.226.211"
	# HRS_IMG_ADDRESS_CANDIDATE_SG = "161.202.164.126"

	# WEBSOCKET_IP = "218.245.4.40"
	echo "WEBSOCKET_IP = \"${hrs_websck_ip}\"" >> ${config_file}

	# HRS_WEB_ADDRESS = "218.245.4.40:2000"
	echo "HRS_WEB_ADDRESS = \"${hrs_web_addr_port}\"" >> ${config_file}

}

setup_log_path() {
	if [ ! -d ${SERVICE_LOG_PATH} ]; then
		echo "Log path not exist, create it ..."
		mkdir -p ${SERVICE_LOG_PATH}
		check_err "Can not create log path ${SERVICE_LOG_PATH}"
	fi
}

config_daemon() {
	PYTHON_EXE=$(get_python_exec)
	
    cat >${HRS_DAEMON_FILE} <<EOL
#!/bin/bash 
#${HRS_DAEMON_FILE}

### BEGIN INIT INFO 
# Provides:          Viscovery 
# Required-Start:    \$remote_fs \$syslog 
# Required-Stop:     \$remote_fs \$syslog 
# Default-Start:     2 3 4 5 
# Default-Stop:      0 1 6 
# Short-Description: vds_hrs startup script 
# Description:       start VDS_HRS daemons: websocket and gevent_server 
### END INIT INFO

get_pid_for_hrs_gevent_server() {
    # purpose: fix vds_es_server has a daemon name run_gevent_server issue
    
    echo \$(ps -ef | grep gevent_server | grep -v grep | grep -v run_gevent_server | awk '{print \$2}')
}

get_pid_by_name() {
    [ -z \${1} ] && echo "ERR Param in get_pid_by_name" && exit 2
    echo \$(ps -ef | grep \${1} | grep -v grep | awk '{print \$2}')
}

stop_daemon_by_name() {
    [ -z \${1} ] && echo "ERR Param in stop_daemon_by_name" && exit 2
    pid=\$(get_pid_by_name \${1})
    if [ -z \${pid} ]; then
        echo "daemon \${1} not exist, skip"
    else
        echo "stop daemon \${1} ..."
        kill -2 \${pid}
        sleep 2
        pid=\$(get_pid_by_name \${1})
        if [ ! -z \${pid} ]; then
            echo "daemon \${1} kill signal 2 fail, try again..."
            kill -2 \${pid}
            sleep 2
        fi
        pid=\$(get_pid_by_name \${1})
        if [ ! -z \${pid} ]; then
            echo "ERROR: stop daemon \${1} fail"
        fi
    fi
}

case "\$1" in

    start)
        echo "Starting VDS_HRS service ..."
        export LC_ALL=C
        export PATH

		#export PYTHONPATH=/root/Env/vcms/lib/python2.7/site-packages
		
        # websocket_server daemon
        if [ -z \$(get_pid_by_name websocket_server) ]; then
            cd ${INSTALL_PATH}/websocket
            exec ${PYTHON_EXE} websocket_server.py >> ${SERVICE_LOG_PATH}/websocket_server.log 2>&1 &
            sleep 2
            if [ -z \$(get_pid_by_name websocket_server) ]; then
                echo "ERR: fail to start HRS websocket_server daemon"
            else
                echo "HRS websocket_server daemon started"
            fi
        else
            echo "HRS websocket_server daemon already exist, skip"
        fi

        # gevent_server daemon
        if [ -z \$(get_pid_for_hrs_gevent_server) ]; then
            cd ${INSTALL_PATH}/hrs_web
            exec ${PYTHON_EXE} gevent_server.py >> ${SERVICE_LOG_PATH}/gevent_server.log 2>&1 &
            sleep 2
            if [ -z \$(get_pid_for_hrs_gevent_server) ]; then
                echo "ERR: fail to start HRS gevent_server daemon"
            else
                echo "HRS gevent_server daemon started"
            fi
        else
            echo "HRS gevent_server daemon already exist, skip"
        fi
        
		;;
    stop)
        echo "Stopping VDS_HRS service ..."
        # stop HRS websocket_server
        stop_daemon_by_name websocket_server

        # stop HRS gevent_server
        pid=\$(get_pid_for_hrs_gevent_server)
        if [ -z \${pid} ]; then
            echo "daemon gevent_server not exist, skip"
        else
            echo "stop daemon gevent_server ..."
            kill -2 \${pid}
            sleep 2
            pid=\$(get_pid_for_hrs_gevent_server)
            if [ ! -z \${pid} ]; then
                echo "daemon gevent_server kill signal 2 fail, try again..."
                kill -2 \${pid}
                sleep 2
            fi
            pid=\$(get_pid_for_hrs_gevent_server)
            if [ ! -z \${pid} ]; then
                echo "ERROR: stop daemon gevent_server fail"
            fi
        fi

        ;;
    *)
        echo "Usage: ${HRS_DAEMON_FILE} start|stop"
        exit 1
        ;;
esac

exit 0
EOL
    check_err "Can not create vds_hrs daemon file ${HRS_DAEMON_FILE}"

}

parse_args() {
    model_list=
    optstring=b:d:u:p:i:r:w:s:
    while getopts $optstring opt
    do
    case $opt in
      b) host_vds=$OPTARG;;
      d) host_db=$OPTARG;;
      u) db_user=$OPTARG;;
      p) db_passwd=$OPTARG;;
      i) db_name=$OPTARG;;
      r) host_mq=$OPTARG;;
      w) hrs_websck_ip=$OPTARG;;
      s) hrs_web_addr_port=$OPTARG;;
      *) usage;
        esac
    done

    # check VDS_ADDR
    [ -z "${host_vds}" ] && echo "No VDS_ADDR is specified!" && usage && exit 1

    # check DB_ADDR
    [ -z "${host_db}" ] && echo "No DB_ADDR is specified!" && usage && exit 1

    # check DB_USER
    [ -z "${db_user}" ] && echo "No DB_USER is specified!" && usage && exit 1

    # check DB_PWD
    [ -z "${db_passwd}" ] && echo "No DB_PWD is specified!" && usage && exit 1

    # check DB_NAME
    [ -z "${db_name}" ] && echo "No DB_NAME is specified!" && usage && exit 1

    # check MQ_ADDR
    [ -z "${host_mq}" ] && echo "No MQ_ADDR is specified!" && usage && exit 1

    # check MQ_ADDR
    [ -z "${hrs_websck_ip}" ] && echo "No WEBSOCKET_IP is specified!" && usage && exit 1

    # check MQ_ADDR
    [ -z "${hrs_web_addr_port}" ] && echo "No HRS_WEB_ADDRESS_PORT is specified!" && usage && exit 1

}


parse_args $@
config_package
install_package ${SRC_DIR} ${INSTALL_PATH}
#setup_symbolic_link_path
setup_log_path
config_daemon
set_daemon_default ${HRS_DAEMON_FILE}

echo "install vds_hrs success."
