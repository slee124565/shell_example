#!/bin/bash -x

PORT_FACE=5101
PORT_OBJECT=5106
PORT_SCENE=5107
INSTALL_PATH=/usr/share/vhost
VHOST_LOG_PATH=/var/log/vhost
VHOST_DAEMON_FILE=/etc/init.d/vhost

#INSTALL_PATH=~/workspace/tmp/vhost
#VHOST_DAEMON_FILE=~/workspace/vhost_initd

FILE_PATH=$(echo $(cd $(dirname "$0") && pwd -P)/$(basename "$0"))
BASEDIR=$(dirname "$(dirname "$(dirname "${FILE_PATH}")")")
echo "BASEDIR: ${BASEDIR}"
SRC_DIR=${BASEDIR}"/vhost"
echo "vhost source path ${SRC_DIR}"

source ../util.sh

usage()
{
more <<EOM

Usage:

${0##*/} -l <LOCAL_IP> -p <PUBLIC_IP> -m <MODEL_ID> -o <PORT> -a <VDS_URL> -u <OUTPUT_PATH> -r <REGION_ID>

    -l <LOCAL_IP> machine local IP
    
    -p <PUBLIC_IP> machine public IP

    -m <MODEL_ID> recognition model ID, e.g. 1:face, 6:object, 7:secene
    
    -o <PORT> model host listen socket port

    -a <VDS_URL> VDS web URL

    -u <OUTPUT_PATH> result file save directory

    -r <REDION_ID> machine region code, e.g. 1:BJ, 1:HK, 3:SG

For example
    install all model
    ./${0##*/} -l 127.0.0.1 -p 218.245.4.38 -m all -a http://vds-api.com:8080 -u /volume/upload -r 3

    install face model
    ./${0##*/} -l 127.0.0.1 -p 218.245.4.38 -m face -o 5101 -a http://vds-api.com:8080 -u /volume/upload -r 3 

    install object model
    ./${0##*/} -l 127.0.0.1 -p 218.245.4.38 -m object -o 5106 -a http://vds-api.com:8080 -u /volume/upload -r 3

    install scene model
    ./${0##*/} -l 127.0.0.1 -p 218.245.4.38 -m scene -o 5107 -a http://vds-api.com:8080 -u /volume/upload -r 3
EOM
}

config_host() {

    model_options="face object scene"
    model_check=$(echo "${model_options}" | grep "${model}")

    if [ -n "${model_check}" ]; then
        [[ ${model} == "face" ]] && model_id=1 
        [[ ${model} == "object" ]] && model_id=6
        [[ ${model} == "scene" ]] && model_id=7
        config_model_host
    elif [ "all" == "${model}" ]; then
        for opt in ${model_options}
        do
            [[ ${opt} == "face" ]] && model_id=1 && model_port=$PORT_FACE
            [[ ${opt} == "object" ]] && model_id=6 && model_port=$PORT_OBJECT
            [[ ${opt} == "scene" ]] && model_id=7 && model_port=$PORT_SCENE
            config_model_host
        done
    else
        echo "param model error ${model}" && return -1
    fi
}

config_model_host() {

    if [ "$model_id" == "1" ]; then
        sub_dir=face_host
    elif [ "$model_id" == "6" ]; then
        sub_dir=object_host
    elif [ "$model_id" == "7" ]; then
        sub_dir=scene_host
    else
        echo "param model_id error ${model_id}" && return -1
    fi

    model_config_file=${SRC_DIR}/${sub_dir}/config.ini
    [ ! -f ${model_config_file} ] && echo "config model host fail!" && exit 2
    sed -i '/LOCALIP=/ c\LOCALIP='${local_ip} ${model_config_file}
    sed -i '/PUBLICIP=/ c\PUBLICIP='${public_ip} ${model_config_file}
    sed -i '/PORT=/ c\PORT='${model_port} ${model_config_file}
    sed -i '/MODEL=/ c\MODEL='${model_id} ${model_config_file}
    sed -i '/API_HOST=/ c\API_HOST='${vds_url} ${model_config_file}
    sed -i '/OUTPUT_PATH=/ c\OUTPUT_PATH='${output_path} ${model_config_file}
    sed -i '/REGION=/ c\REGION='${region_id} ${model_config_file}

}

create_all_model_daemon_file() {
    PYTHON_EXE=$(get_python_exec)

    cat >${VHOST_DAEMON_FILE} <<EOL
#!/bin/bash 
#${VHOST_DAEMON_FILE}

### BEGIN INIT INFO 
# Provides:          Viscovery 
# Required-Start:    \$remote_fs \$syslog 
# Required-Stop:     \$remote_fs \$syslog 
# Default-Start:     2 3 4 5 
# Default-Stop:      0 1 6 
# Short-Description: vhost startup script 
# Description:       start vhost for model face, object, scene 
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
		echo "Starting vhost and RCNN service"
		export LC_ALL=C
		export PATH
		
		#export PYTHONPATH=/root/Env/vhost/lib/python2.7/site-packages

        # face_socket_server daemon
        if [ -z \$(get_pid_by_name face_socket_server) ]; then
            exec ${PYTHON_EXE} ${INSTALL_PATH}/face_host/face_socket_server.py -d 1 >> ${VHOST_LOG_PATH}/vhost_face.log 2>&1 &
            sleep 2
            if [ -z \$(get_pid_by_name face_socket_server) ]; then
                echo "ERR: fail to start vhost face_socket_server daemon"
            else
                echo "vhost face_socket_server daemon started"
            fi
        else
            echo "vhost face_socket_server daemon already exist, skip"
        fi
		
        # object_socket_server daemon
        if [ -z \$(get_pid_by_name object_socket_server) ]; then
            exec ${PYTHON_EXE} ${INSTALL_PATH}/object_host/object_socket_server.py -d 1 >> ${VHOST_LOG_PATH}/vhost_object.log 2>&1 &
            sleep 2
            if [ -z \$(get_pid_by_name object_socket_server) ]; then
                echo "ERR: fail to start vhost object_socket_server daemon"
            else
                echo "vhost object_socket_server daemon started"
            fi
        else
            echo "vhost object_socket_server daemon already exist, skip"
        fi

        # scene_socket_server daemon
        if [ -z \$(get_pid_by_name scene_socket_server) ]; then
            exec ${PYTHON_EXE} ${INSTALL_PATH}/scene_host/scene_socket_server.py -d 1 >> ${VHOST_LOG_PATH}/vhost_scene.log 2>&1 &
            sleep 2
            if [ -z \$(get_pid_by_name scene_socket_server) ]; then
                echo "ERR: fail to start vhost scene_socket_server daemon"
            else
                echo "vhost scene_socket_server daemon started"
            fi
        else
            echo "vhost scene_socket_server daemon already exist, skip"
        fi
		;;
  stop)
        echo "Stopping vhost service ..."
        # stop face_socket_server
        stop_daemon_by_name face_socket_server

        # stop object_socket_server
        stop_daemon_by_name object_socket_server

        # stop scene_socket_server
        stop_daemon_by_name scene_socket_server

		;;
  *)
      echo "Usage: ${VHOST_DAEMON_FILE} start|stop"
      exit 1
      ;;
esac

exit 0
EOL
}

config_daemon() {

    # setup vhost log path
    [[ ! -d ${VHOST_LOG_PATH} ]] && echo "crate vhost log path ${VHOST_LOG_PATH}" && mkdir -p ${VHOST_LOG_PATH};

    # create vhost daemon file
    create_all_model_daemon_file

    # strip uninstalled model from daemon file script
    [[ ${model} == "face" ]] && sed -i '/object_socket_server/d' ${VHOST_DAEMON_FILE} && sed -i '/scene_socket_server/d' ${VHOST_DAEMON_FILE}
    [[ ${model} == "object" ]] && sed -i '/face_socket_server/d' ${VHOST_DAEMON_FILE} && sed -i '/scene_socket_server/d' ${VHOST_DAEMON_FILE}
    [[ ${model} == "scene" ]] && sed -i '/object_socket_server/d' ${VHOST_DAEMON_FILE} && sed -i '/face_socket_server/d' ${VHOST_DAEMON_FILE}

    # set daemon file executable
    chmod a+x ${VHOST_DAEMON_FILE}
}

start_vhost() {
    read -p "Do you want to start vhost daemon??[y/N]: " yn
    [[ -z ${yn} ]] && yn=N
    case $yn in
        [Yy]* ) service vhost start;;
        * ) echo 'vhost service not started' && exit;;
    esac
}

parse_args() {
    optstring=l:p:m:o:a:u:r:
    while getopts $optstring opt
    do
    case $opt in
      l) local_ip=$OPTARG;;
      p) public_ip=$OPTARG;;
      m) model=$OPTARG;;
      o) model_port=$OPTARG;;
      a) vds_url=$OPTARG;;
      u) output_path=$OPTARG;;
      r) region_id=$OPTARG;;
      *) usage;
        esac
    done

    # check LOCAL_IP
    [ -z "$local_ip" ] && echo "No LOCAL_IP is specified!" && usage && exit 1

    # check PUBLIC_IP
    [ -z "$public_ip" ] && echo "No PUBLIC_IP is specified!" && usage && exit 1

    # check MODEL_ID
    [ -z "$model" ] && echo "No MODEL_ID is specified!" && usage && exit 1

    if [ ! $model == "all" ]; then
        # check MODEL_PORT
        [ -z "$model_port" ] && echo "No MODEL_PORT is specified!" && usage && exit 1
    fi

    # check VDS_URL
    [ -z "$vds_url" ] && echo "No VDS_URL is specified!" && usage && exit 1

    # check OUTPUT_PATH
    [ -z "$output_path" ] && echo "No JSON OUTPUT_PATH is specified!" && usage && exit 1

    # check region_id
    [ -z "$region_id" ] && echo "No REGION_ID is specified!" && usage && exit 1
}

parse_args $@
config_host
install_package ${SRC_DIR} ${INSTALL_PATH}
config_daemon
#start_vhost


