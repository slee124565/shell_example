#!/bin/bash -x

export LC_ALL=C
INSTALL_PATH=/usr/share/vds/vds_api
SERVICE_LOG_PATH=/var/log/vds
VDS_DAEMON_FILE=/etc/init.d/vds_api

FILE_PATH=$(echo $(cd $(dirname "$0") && pwd -P)/$(basename "$0"))
BASEDIR=$(dirname "$(dirname "$(dirname "${FILE_PATH}")")")
echo "BASEDIR: ${BASEDIR}"
SRC_DIR=${BASEDIR}"/vds_api"
echo "vds_api source path ${SRC_DIR}"

source ../util.sh

usage()
{
more <<EOM

Usage:

${0##*/} -a <VCMS_ADDR> -b <VDS_ADDR> -c <VDS_PORT> -d <DB_ADDR> -u <DB_USER> -p <DB_PWD> -i <DB_NAME> -r <MQ_ADDR> -o <NFS_FOLDER>

    -a <VCMS_ADDR> VCMS web domain name or IP address
    
    -b <VDS_ADDR> VDS web domain name or IP address

    -c <VDS_PORT> VDS web PORT listen, default 80

    -d <DB_ADDR> database server internal IP address

    -u <DB_USER> database login username for VDS

    -p <DB_PWD> database login password for VDS

    -i <DB_NAME> database instance name for VDS

    -r <MQ_ADDR> RabbitMQ server IP address

    -o <NFS_FOLDER> the root path for VDS result json folder 

For example

    ./${0##*/} -a vcms2.xxx.co -b vds-api2.xxx.co -d 172.17.0.8 -u vds-api -p vds-api  -i vds-api -r 172.17.0.8 -o /volume/vds/upload

EOM
}

config_package() {

    # remove existing change in source if .git control
    [ -d "${SRC_DIR}/.git" ] && cd ${SRC_DIR} && git checkout -f && cd -

	# change param in VDS_API module_config.py file
	config_file=${SRC_DIR}"/model_config.py"
	
	[ ! -f ${config_file} ] && echo "VDS_API config file ${config_file} not exist!" && exit 1

	echo "" >> ${config_file}
	 
	# VCMS_ADDRESS = "vcms.xxx.co"
	sed -i '/VCMS_ADDRESS =/ c\    VCMS_ADDRESS = '"\"${host_vcms}\"" ${config_file}

	# VDS_ADDRESS = "vds-api.xxx.co"
	sed -i '/VDS_ADDRESS =/ c\    VDS_ADDRESS = '"\"${host_vds}:${host_vds_port}\"" ${config_file}

	# DB_HOST_IP = "172.17.0.4"
	sed -i '/DB_HOST_IP =/ c\    DB_HOST_IP = '"\"${host_db}\"" ${config_file}

	# RABBITMQ_IP = "172.17.0.4"
	sed -i '/RABBITMQ_IP =/ c\    RABBITMQ_IP = '"\"${host_mq}\"" ${config_file}

	# DB_USER_NAME = "vds_api"
	sed -i '/DB_USER_NAME =/ c\    DB_USER_NAME = '"\"${db_user}\"" ${config_file}

	# DB_PASS_WORD = "zaq12wsx"
	sed -i '/DB_PASS_WORD =/ c\    DB_PASS_WORD = '"\"${db_passwd}\"" ${config_file}

	# DB_NAME = "vds_api"
	sed -i '/DB_NAME =/ c\    DB_NAME = '"\"${db_name}\"" ${config_file}

	# REC_MACHINE_TYPE = 1

	# NFS_FOLDER = "/volume/vds/upload"
	sed -i '/NFS_FOLDER =/ c\    NFS_FOLDER = '"\"${nfs_path}\"" ${config_file}

	# FITAMOS_IN_USE = "fos"

	# UPDATE_JOB_STATUS_API = "http://%s/Video/update_job_status" % VCMS_ADDRESS
	sed -i '/UPDATE_JOB_STATUS_API =/ c\UPDATE_JOB_STATUS_API = '"\"http://%s/Video/update_job_status\" % VCMS_ADDRESS" ${config_file}

	# LOG_PATH = "/var/log/vds_api/"
}

setup_symbolic_link_path() {
	# create a symbolic link from NFS_FOLDER to dest_path/vds_api_web/static
	rm -f ${INSTALL_PATH}/vds_api_web/static
	ln -s ${nfs_path} ${INSTALL_PATH}/vds_api_web/static
	check_err "Can not create symbolic link from ${nfs_path} to ${INSTALL_PATH}/vds_api_web/static"
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
	
    cat >${VDS_DAEMON_FILE} <<EOL
#!/bin/bash 
#${VDS_DAEMON_FILE}

### BEGIN INIT INFO 
# Provides:          Viscovery 
# Required-Start:    \$remote_fs \$syslog 
# Required-Stop:     \$remote_fs \$syslog 
# Default-Start:     2 3 4 5 
# Default-Stop:      0 1 6 
# Short-Description: vds_api startup script 
# Description:       start VDS ffmpeg, relay, object_tracking, scene_cut daemons 
### END INIT INFO

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
        echo "Starting VDS_API service..."
        export LC_ALL=C
        export PATH

		#export PYTHONPATH=/root/Env/vcms/lib/python2.7/site-packages
		
		# ffmpeg daemon
		if [ -z \$(get_pid_by_name run_ffmpeg) ]; then
			exec ${PYTHON_EXE} ${INSTALL_PATH}/run_ffmpeg.py >> ${SERVICE_LOG_PATH}/ffmpeg_cut.log 2>&1 &
			sleep 2
			if [ -z \$(get_pid_by_name run_ffmpeg) ]; then
	        	echo "ERR: fail to start VDS_API ffmpeg daemon"
			else
	        	echo "VDS_API ffmpeg daemon started"
	        fi
		else
			echo "VDS_API ffmpeg daemon already exist, skip"
		fi

        # object_tracking daemon
		if [ -z \$(get_pid_by_name run_object_tracking) ]; then
			exec ${PYTHON_EXE} ${INSTALL_PATH}/run_object_tracking.py >> ${SERVICE_LOG_PATH}/object_tracking.log 2>&1 &
			sleep 2
			if [ -z \$(get_pid_by_name run_object_tracking) ]; then
	        	echo "ERR: faile to start VDS_API object_tracking daemon"
			else
	        	echo "VDS_API object_tracking daemon started"
	        fi
		else
			echo "VDS_API object_tracking daemon already exist, skip"
		fi
	
        # scene_cut daemon
		if [ -z \$(get_pid_by_name run_scenecut) ]; then
			exec ${PYTHON_EXE} ${INSTALL_PATH}/run_scenecut.py >> ${SERVICE_LOG_PATH}/scene_cut.log 2>&1 &
			sleep 2
			if [ -z \$(get_pid_by_name run_scenecut) ]; then
	        	echo "ERR: fail to start VDS_API scene_cut daemon"
			else
	        	echo "VDS_API scene_cut daemon started"
	        fi
		else
			echo "VDS_API scene_cut daemon already exist, skip"
		fi
	
        # relay daemon
		if [ -z \$(get_pid_by_name run_relay) ]; then
			exec ${PYTHON_EXE} ${INSTALL_PATH}/run_relay.py >> ${SERVICE_LOG_PATH}/vds_relay.log 2>&1 &
			sleep 2
			if [ -z \$(get_pid_by_name run_relay) ]; then
	        	echo "ERR: fail to start VDS_API relay daemon"
			else
	        	echo "VDS_API relay daemon started"
	        fi
		else
			echo "VDS_API relay daemon already exist, skip"
		fi
	
		;;
    stop)
        echo "Stopping VDS_API service ..."
        # stop ffmpeg
        stop_daemon_by_name run_ffmpeg

        # stop object_tracking
        stop_daemon_by_name run_object_tracking

        # stop scene_cut
        stop_daemon_by_name run_scenecut

        # stop relay
        stop_daemon_by_name run_relay

        ;;
    *)
        echo "Usage: ${VDS_DAEMON_FILE} start|stop"
        exit 1
        ;;
esac

exit 0
EOL
    check_err "Can not create vds_api daemon file ${VDS_DAEMON_FILE}"

}

config_nginx() {
	nginx_conf_file=${NGINX_CONFIG_INSTALL_PATH}/vds_api.conf

    # if host_vds is ip address, set nginx server_name = _ 
    nginx_serv_name=${host_vds}
    [ ! -z $(echo ${nginx_serv_name} | grep -Eo '([0-9]*\.){3}[0-9]*') ] && nginx_serv_name="_"

    cat >${nginx_conf_file} <<EOL
server {
    listen       ${host_vds_port};
    server_name  ${nginx_serv_name};
    location /{
        include uwsgi_params;
        uwsgi_pass unix:/var/run/vds_api_uwsgi.sock;
    }
    location ^~ /ui_static/{
        root ${INSTALL_PATH}/vds_api_web/ui;
    }
    location ^~ /static/{
        root ${INSTALL_PATH}/vds_api_web;
        autoindex on;
    }
}	
EOL
    check_err "Can not create nginx config file ${nginx_conf_file}"
}

config_uwsgi() {
	uwsig_conf_file=${UWSGI_CONFIG_INSTALL_PATH}/vds_api.ini
    cat >${uwsig_conf_file} <<EOL
[uwsgi]
master = true
workers = 4

enable_threads = true

threads = 1000

reload-mercy = 60

vacuum = true

listen = 100

max-requests = 50000

chmod-socket = 666

socket = /var/run/vds_api_uwsgi.sock

#home = /usr/local/lib/python2.7
chdir = ${INSTALL_PATH}

module = app

callable = app

logto = /var/log/uwsgi/apps/vds_api.log

touch-reload = ${INSTALL_PATH}/app.py

pidfile = /var/run/vds_api_uwsgi.pid

log-maxsize = 100000000
buffer-size = 65535
limit-post = 10485760

EOL
    check_err "Can not create uwsig config file ${uwsig_conf_file}"
}

parse_args() {
    model_list=
    optstring=a:b:d:u:p:i:r:o:c:
    while getopts $optstring opt
    do
    case $opt in
      a) host_vcms=$OPTARG;;
      b) host_vds=$OPTARG;;
      c) host_vds_port=$OPTARG;;
      d) host_db=$OPTARG;;
      u) db_user=$OPTARG;;
      p) db_passwd=$OPTARG;;
      i) db_name=$OPTARG;;
      r) host_mq=$OPTARG;;
      o) nfs_path=$OPTARG;;
      *) usage;
        esac
    done

    # check VCMS_ADDR
    [ -z "${host_vcms}" ] && echo "No VCMS_ADDR is specified!" && usage && exit 1

    # check VDS_ADDR
    [ -z "${host_vds}" ] && echo "No VDS_ADDR is specified!" && usage && exit 1

    # check VDS_ADDR
    [ -z "${host_vds_port}" ] && echo "No VDS_PORT is specified, use default 80." && host_vds_port=80

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

    # check NFS_FOLDER
    [ -z "${nfs_path}" ] && echo "No NFS_FOLDER is specified!" && usage && exit 1
    if [ ! -d "${nfs_path}" ]; then
		echo "NFS_FOLDER not exist, try to create it..."
		mkdir -p ${nfs_path}
		check_err "Can not create NFS_FOLDER, stop installation!" 
	fi

}


parse_args $@
config_package
install_package ${SRC_DIR} ${INSTALL_PATH}
setup_symbolic_link_path
setup_log_path
config_daemon
set_daemon_default ${VDS_DAEMON_FILE}
config_nginx
config_uwsgi

echo "install vds_api success."

