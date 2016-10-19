#!/bin/bash -x

export LC_ALL=C

INSTALL_PATH=/usr/share/rcnn
RCNN_LOG_PATH=/var/log/rcnn
RCNN_DAEMON_FILE=/etc/init.d/rcnn

#INSTALL_PATH=~/workspace/tmp/rcnn
#RCNN_DAEMON_FILE=~/workspace/tmp/rcnn/rcnn_initd

FILE_PATH=$(echo $(cd $(dirname "$0") && pwd -P)/$(basename "$0"))
BASEDIR=$(dirname "$(dirname "$(dirname "${FILE_PATH}")")")
echo "BASEDIR: ${BASEDIR}"
SRC_DIR=${BASEDIR}"/orbit-si"
echo "rcnn source path ${SRC_DIR}"

source ../util.sh

usage()
{
more <<EOM

Usage:

${0##*/} -f <FACE_PORT> -o <OBJECT_PORT> -c <CAR_PORT> -d <DRINK_PORT> -s <SCENE_PORT> -p <PATCHES_PATH> -m <MODEL_PATH>

    -f <FACE_PORT> socket listen port for face model
    
    -o <OBJECT_PORT> socket listen port for object model

    -c <CAR_PORT> socket listen port for car model

    -d <DRINK_PORT> socket listen port for bottle model

    -s <SCENE_PORT> socket listen port for scene model

    -p <PATCHES_PATH> the path for rcnn to create patches files

    -m <MODEL_PATH> the path for rcnn rec model file release root path

For example
    install all model with customize port
    ./${0##*/} -f 6101 -o 6106 -c 6116 -d 6126 -s 6107 -p /volume/vds/upload/patches -o /volume/model
EOM
}

create_patches_path() {
    if [ ! -d ${patches_path} ]; then
        echo "orbit patches path not exist, create it"
        mkdir -p ${patches_path}
        check_err "Create Orbit pathces path fail!"
    fi
}


setup_patches_path() {
    
    if [ ! -d ${patches_path} ]; then
        echo "orbit patches path not exist, create it"
        mkdir -p ${patches_path}
        check_err "Create Orbit pathces path fail!"
    fi

    rm -f ${INSTALL_PATH}/Release/patches
    ln -s $patches_path ${INSTALL_PATH}/Release/patches
    check_err "Can not setup rcnn patches path"

}

create_rcnn_daemon_template_file() {

    cat >${RCNN_DAEMON_FILE} <<EOL
#!/bin/bash 
#${RCNN_DAEMON_FILE}

### BEGIN INIT INFO 
# Provides:          Viscovery 
# Required-Start:    \$remote_fs \$syslog 
# Required-Stop:     \$remote_fs \$syslog 
# Default-Start:     2 3 4 5 
# Default-Stop:      0 1 6 
# Short-Description: rcnn startup script 
# Description:       start vhost for model face, object, car, bottle, scene 
### END INIT INFO


case "\$1" in

    start)
        echo "Starting RCNN service ..."
        export LC_ALL=C
        export CUDA_HOME=/usr/local/cuda-7.5
        export LD_LIBRARY_PATH=\${CUDA_HOME}/lib64
        PATH=\${CUDA_HOME}/bin:\${PATH}
        export PATH

        cd ${INSTALL_PATH}/Release       
        # CMD_START 

        sleep 5
        ;;
    stop)
        echo "Stopping RCNN service ..."
        killall -2 QQuando
        sleep 3
        ;;
    *)
        echo "Usage: ${RCNN_DAEMON_FILE} start|stop"
        exit 1
        ;;
esac

exit 0
EOL
    check_err "Can not create rcnn daemon template file ${RCNN_DAEMON_FILE}"
}

insert_daemon_model_cmd() {

    CMD="exec ./QQuando --start MODEL_NAME --port MODEL_PORT >> ${RCNN_LOG_PATH}/MODEL_NAME.log 2>&1 &"
    model_cmd="        "$(echo $CMD | sed 's/MODEL_NAME/'$1'/g' | sed 's/MODEL_PORT/'$2'/')
    num=$(sed -n '/CMD_START/ =' ${RCNN_DAEMON_FILE})
    ((num=num+1))
    sed -i "${num}i\\${model_cmd}" ${RCNN_DAEMON_FILE}
}

setup_log_path() {
    if [ ! -d ${RCNN_LOG_PATH} ]; then
        echo "rcnn service log path not exist, create it."
        mkdir -p ${RCNN_LOG_PATH}
        checkerr "Can not create rcnn log path ${RCNN_LOG_PATH}"
    fi
}

config_model_file_path() {
	# setup all model (face,object,scene,car,bottle) folder symoblic link for rcnn
	model_list="face object scene car bottle"
	
	[ ! -d ${INSTALL_PATH}/Release/model ] && mkdir -p ${INSTALL_PATH}/Release/model
	for opt in ${model_list}
	do
		[ -d ${INSTALL_PATH}/Release/model/${opt} ] && rm ${INSTALL_PATH}/Release/model/${opt}
		[ -d ${model_path}/${opt} ] && ln -s ${model_path}/${opt} ${INSTALL_PATH}/Release/model/${opt}
        check_err "config rec model ${opt} path fail! "
	done
	
}

config_daemon() {

    create_rcnn_daemon_template_file

    # insert model start up command
    for opt in ${model_list}
    do
        port_name=${opt}_port
        insert_daemon_model_cmd ${opt} ${!port_name}
    done
    
    chmod a+x ${RCNN_DAEMON_FILE}
    
}

set_daemon_default() {
    
    daemon_name=`basename ${RCNN_DAEMON_FILE}`
    update-rc.d ${daemon_name} defaults
    check_err "config daemon ${daemon_name} defaults fail"
}

parse_args() {
    model_list=
    optstring=f:o:c:d:s:p:m:
    while getopts $optstring opt
    do
    case $opt in
      f) face_port=$OPTARG && model_list="face ${model_list}";;
      o) object_port=$OPTARG && model_list="object ${model_list}";;
      c) car_port=$OPTARG && model_list="car ${model_list}";;
      d) bottle_port=$OPTARG && model_list="bottle ${model_list}";;
      s) scene_port=$OPTARG && model_list="scene ${model_list}";;
      p) patches_path=$OPTARG;;
      m) model_path=$OPTARG;;
      *) usage;
        esac
    done

    # check patches_path
    [ -z "${patches_path}" ] && echo "No PATCHES_PATH is specified!" && usage && exit 1
    #[ ! -d ${patches_path} ] && echo "PATCHES_PATH is not exist, please create it inadvance!" && exit 1

    # check existing model port
    [ -z "${face_port}${object_port}${car_port}${bottle_port}${scene_port}" ] && echo "No model port is specified!" && usage && exit 1
    
    # check patches_path
    [ -z "${model_path}" ] && echo "No MODEL_PATH is specified!" && usage && exit 1
    [ ! -d ${model_path} ] && echo "MODEL_PATH is not exist, please create it inadvance!" && exit 1

    echo "install with model: ${model_list}"
}

parse_args $@
install_package ${SRC_DIR} ${INSTALL_PATH}
setup_patches_path
setup_log_path
config_model_file_path
config_daemon
set_daemon_default
