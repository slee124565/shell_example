#!/bin/bash -x

export LC_ALL=C
INSTALL_PATH=/usr/share/vds/vds_vcms
SERVICE_LOG_PATH="/var/log/vcms /var/log/vcms_log"

FILE_PATH=$(echo $(cd $(dirname "$0") && pwd -P)/$(basename "$0"))
BASEDIR=$(dirname "$(dirname "$(dirname "${FILE_PATH}")")")
echo "BASEDIR: ${BASEDIR}"
SRC_DIR=${BASEDIR}"/vds_vcms"
echo "vds_vcms source path ${SRC_DIR}"

pwd
source ../util.sh


usage()
{
more <<EOM

Usage:

${0##*/} -a <VCMS_ADDR> -t <VCMS_PORT> -b <VDS_ADDR> -c <VDS_PORT> -d <DB_ADDR> -u <DB_USER> -p <DB_PWD> -i <DB_NAME> -j <PLAYER_JSON> -o <NFS_FOLDER>

    -a <VCMS_ADDR> VCMS web domain name or IP address
    
    -t <VCMS_PORT> VCMS web port listen, default 80
    
    -b <VDS_ADDR> VDS web domain name or IP address

    -c <VDS_PORT> VDS web port listen, default 80

    -d <DB_ADDR> database server internal IP address

    -u <DB_USER> database login username for VCMS

    -p <DB_PWD> database login password for VCMS

    -i <DB_NAME> database instance name for VCMS

    -j <PLAYER_JSON> Player JSON path for VCMS

    -o <NFS_FOLDER> the root path for VDS result json folder 


For example

    ./${0##*/} -a vcms2.xxxxx.co -t 80 -b vds-api2.xxxxx.co -c 80 -d 172.17.0.8 -u vcms -p vcms -i vcms -j /volume/vcms/player_json -o /volume/vds/upload

EOM
}

config_package() {

    # remove existing change in source if .git control
    [ -d "${SRC_DIR}/.git" ] && cd ${SRC_DIR} && git checkout -f && cd -

	# change param in VCMS config.py file
	config_file=${SRC_DIR}"/config.py"
	
	[ ! -f ${config_file} ] && echo "VCMS config file ${config_file} not exist!" && exit 1

	# VDS_IP = "vds-api.xxxxx.cn"
	sed -i '/VDS_IP =/ c\    VDS_IP = '"\"${host_vds}\"" ${config_file}

	# VDS_IP_PORT = 80
	sed -i '/VDS_IP_PORT =/ c\    VDS_IP_PORT = '"\"${host_vds_port}\"" ${config_file}

	# VCMS_HOST = "vcms.xxxxx.cn"
	sed -i '/VCMS_HOST =/ c\    VCMS_HOST = '"\"${host_vcms}\"" ${config_file}

	# DB_HOST_IP = "172.16.0.102"
	sed -i '/DB_HOST_IP =/ c\    DB_HOST_IP = '"\"${host_db}\"" ${config_file}

	# DB_USER_NAME = "xxxxx"
	sed -i '/DB_USER_NAME =/ c\    DB_USER_NAME = '"\"${db_user}\"" ${config_file}

	# DB_NAME = "vcms"
	sed -i '/DB_NAME =/ c\    DB_NAME = '"\"${db_name}\"" ${config_file}

	# DB_PASS_WORD = "xxxxx1qaz2wsx"
	sed -i '/DB_PASS_WORD =/ c\    DB_PASS_WORD = '"\"${db_passwd}\"" ${config_file}

	# LOG_PATH = "/var/log/vcms_log/"
	sed -i '/LOG_PATH =/ c\    LOG_PATH = '"\"${SERVICE_LOG_PATH}\"" ${config_file}

	# PLAYER_JSON = "/home/ec2-user/player_json"
	sed -i '/PLAYER_JSON =/ c\    PLAYER_JSON = '"\"${player_json_path}\"" ${config_file}

	# VDS_CLASSMAP_URL= "http://%s:%s/classmap"%(VDS_IP,str(VDS_IP_PORT))
	sed -i '/VDS_CLASSMAP_URL =/ c\    VDS_CLASSMAP_URL = '"\"http://%s:%s/classmap\"%(VDS_IP,str(VDS_IP_PORT))" ${config_file}
    sed -i '/VDS_CLASSMAP_URL=/ c\    VDS_CLASSMAP_URL = '"\"http://%s:%s/classmap\"%(VDS_IP,str(VDS_IP_PORT))" ${config_file}

	# JSON_PATH = "/volume/vds/upload/json"
	sed -i '/JSON_PATH =/ c\    JSON_PATH = '"\"${nfs_path}\"" ${config_file}

	# IMAGE_PATH = "/home/ec2-user/vds_vcms/vdsapp/static/ad_img/"
	sed -i '/IMAGE_PATH =/ c\    IMAGE_PATH = '"\"${INSTALL_PATH}/vdsapp/static/ad_img/\"" ${config_file}

}

setup_symbolic_link_path() {
	# create a symbolic link from PLAYER_JSON path to dest_path/vdsapp/static/player_json
	rm -f ${INSTALL_PATH}/vdsapp/static/player_json
	ln -s ${player_json_path} ${INSTALL_PATH}/vdsapp/static/player_json
	check_err "Can not create symbolic link from ${player_json_path} to ${INSTALL_PATH}/vdsapp/static/player_json"
}

setup_log_path() {
	if [ ! -d ${SERVICE_LOG_PATH} ]; then
		echo "Log path not exist, create it ..."
		mkdir -p ${SERVICE_LOG_PATH}
		check_err "Can not create log path ${SERVICE_LOG_PATH}"
	fi
}

config_nginx() {
	nginx_conf_file=${NGINX_CONFIG_INSTALL_PATH}/vcms.conf

	# if host_vcms is ip address, set nginx server_name = _ 
    nginx_serv_name=${host_vcms}
	[ ! -z $(echo ${nginx_serv_name} | grep -Eo '([0-9]*\.){3}[0-9]*') ] && nginx_serv_name="_"

    cat >${nginx_conf_file} <<EOL
server {
    listen       ${host_vcms_port};
    server_name  ${nginx_serv_name};
    location /{
        include uwsgi_params;
        uwsgi_pass unix:/var/run/vcms_uwsgi.sock;
    }
    location ^~ /static/{
        root ${INSTALL_PATH}/vdsapp;
    }
}
EOL
    check_err "Can not create nginx config file ${nginx_conf_file}"
}

config_uwsgi() {
	uwsig_conf_file=${UWSGI_CONFIG_INSTALL_PATH}/vcms.ini
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

socket = /var/run/vcms_uwsgi.sock

#home = /usr/local/lib/python2.7
chdir = ${INSTALL_PATH}

module = app

callable = app

logto = /var/log/uwsgi/apps/vcms_uwsgi.log

touch-reload = ${INSTALL_PATH}/app.py

pidfile = /var/run/vcms_uwsgi.pid

log-maxsize = 10000000
buffer-size = 65535
limit-post = 1024000

EOL
    check_err "Can not create uwsig config file ${uwsig_conf_file}"
}

parse_args() {
    model_list=
    optstring=a:b:c:d:u:p:i:j:o:t:
    while getopts $optstring opt
    do
    case $opt in
      a) host_vcms=$OPTARG;;
      t) host_vcms_port=$OPTARG;;
      b) host_vds=$OPTARG;;
      c) host_vds_port=$OPTARG;;
      d) host_db=$OPTARG;;
      u) db_user=$OPTARG;;
      p) db_passwd=$OPTARG;;
      i) db_name=$OPTARG;;
      j) player_json_path=$OPTARG;;
      o) nfs_path=$OPTARG;;
      *) usage;
        esac
    done

    # check VCMS_ADDR
    [ -z "${host_vcms}" ] && echo "No VCMS_ADDR is specified!" && usage && exit 1

    # check VCMS_PORT
    [ -z "${host_vcms_port}" ] && echo "No VCMS_PORT is specified, use default 80." && host_vcms_port=80

    # check VDS_ADDR
    [ -z "${host_vds}" ] && echo "No VDS_ADDR is specified!" && usage && exit 1

    # check VDS_PORT
    [ -z "${host_vds_port}" ] && echo "No VDS_PORT is specified, use default 80." && host_vds_port=80

    # check DB_ADDR
    [ -z "${host_db}" ] && echo "No DB_ADDR is specified!" && usage && exit 1

    # check DB_USER
    [ -z "${db_user}" ] && echo "No DB_USER is specified!" && usage && exit 1

    # check DB_PWD
    [ -z "${db_passwd}" ] && echo "No DB_PWD is specified!" && usage && exit 1

    # check DB_NAME
    [ -z "${db_name}" ] && echo "No DB_NAME is specified!" && usage && exit 1

    # check PLAYER_JSON
    [ -z "${player_json_path}" ] && echo "No PLAYER_JSON is specified!" && usage && exit 1

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
config_nginx
config_uwsgi

echo "install vds_vcms success."

