#!/bin/bash -x

export LC_ALL=C

FILE_PATH=$(echo $(cd $(dirname "$0") && pwd -P)/$(basename "$0"))
BASEDIR=$(dirname "$(dirname "$(dirname "${FILE_PATH}")")")
echo "BASEDIR: ${BASEDIR}"
SRC_DIR=${BASEDIR}"/orbit-si"

source ../util.sh
source ../sys_config.sh

usage()
{
more <<EOM

Usage:

${0##*/} -p <MODEL_ROOT_PATH> -m <MODEL_NAME> -v <GIT_REF>

    -p <MODEL_ROOT_PATH> path for model to be installed
    -m <MODEL_NAME> model name to be install: ${MODEL_NAME_LIST} all
    -v <GIT_REF> revision name or ID for git to checkout, default will be master
    
For example
    install all model 
    ./${0##*/} -p /volume/model -m all

	install or update face model
    ./${0##*/} -p /volume/model -m face -v face_127_tag
	
EOM
}

install_update_model() {
    echo "install rec model: ${model_name}"
	if [ ${model_name} = "all" ]; then
		model_list=${MODEL_NAME_LIST}
	else
		model_list=${model_name}
	fi

    for opt in ${model_list}
    do
        dest_git=${model_root_path}/${opt}
        if [ -d "${dest_git}/.git" ]; then
        	echo "git repo exist for model ${opt}, exec git update process ..."
        	cd ${dest_git}
        	sudo git fetch origin
        	check_err "update model ${opt} fail!"
        	sudo git checkout -f
        	sudo git clean -fx -d
        	sudo git checkout ${git_rev}
        	check_err "model ${opt} update fail"
        else
        	echo "git repo not exist for model ${opt}, create new one ..."
        	sudo rm -rf ${model_root_path}/${opt}
        	sudo mkdir -p ${model_root_path}
        	cd ${model_root_path}
        	sudo git clone ssh://${MODEL_SERVER_ADDR}:${MODEL_SERVER_SSH_PORT}${MODEL_SERVER_ROOT_PATH}/${opt}.git 
        	cd ${opt}
            sudo git checkout ${git_rev}
            check_err "model ${opt} install fail"
        fi
    done
}

model_name=
git_rev="origin/master"
parse_args() {
	
    optstring=p:m:v:
    while getopts $optstring opt
    do
    case $opt in
      p) model_root_path=$OPTARG;;
      m) model_name=$OPTARG;;
      v) git_rev=$OPTARG;;
      *) usage;;
        esac
    done

    # check MODEL_ROOT_PATH
    [ -z "${model_root_path}" ] && echo "No MODEL_ROOT_PATH is specified!" && usage && exit 1

    # check MODEL_NAME
    [ -z "${model_name}" ] && echo "No MODEL_NAME is specified!" && usage && exit 1

    echo "install rec model: ${model_name}"
}

parse_args $@

sudo apt-get update && sudo apt-get -yq install git
install_deploy_key
install_update_model
install_host_origin_key
