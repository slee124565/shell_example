#!/bin/bash -x
  
export LC_ALL=C

source ./module_list.sh

FILE_PATH=$(echo $(cd $(dirname "$0") && pwd -P)/$(basename "$0"))
BASEDIR=$(dirname "$(dirname "${FILE_PATH}")")
echo "BASEDIR: ${BASEDIR}"

source ./util.sh

usage()
{
more <<EOM

Usage:

${0##*/} -b <GIT_REF_NAME>

    -b <GIT_REF_NAME> VDS SW Release Branch Name or Tag Name

    -d <DEPLOY_TYPE> VDS deploy type: std_app, std_rcnn, NONE for all

For example

    ./${0##*/} -b release_20160715

EOM
}

fetch_gitlab_src() {
    cd ${BASEDIR}
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    for proj in ${proj_select_list}
    do
        proj_name=$(basename ${proj} | grep -o '^[^\.]*')
        check_err 'proj filter error'
        [ -d ${proj_name} ] && echo "remove existing folder ${BASEDIR}/${proj_name}" && sudo rm -rf ${proj_name}
        if [ -z "$(echo ${proj} | grep "\-b" )" ]; then
            git clone ${proj} -b ${ref_name}
            check_err "Can not git clone project ${proj} with reference ${ref_name}!"
        else
            git_url=$(echo ${proj} | grep -o '^[^\ ]*')
            git_ref=$(echo ${proj} | sed -n -e 's/^.*-b //p')
            git clone ${git_url} -b ${git_ref}
            check_err "Can not git clone project ${proj} with reference ${ref_name}!"
        fi
    done
    IFS=$SAVEIFS
}

parse_args() {
    model_list=
    optstring=b:d:
    while getopts $optstring opt
    do
    case $opt in
      b) ref_name=$OPTARG;;
      d) deploy_type=$OPTARG;;
      *) usage;
        esac
    done

    # check GIT_REF_NAME
    [ -z "${ref_name}" ] && echo "No GIT_REF_NAME is specified!" && usage && exit 1

    # check DEPLOY_TYPE
    [ -z "${deploy_type}" ] && echo "No DEPLOY_TYPE is specified, set to all"
    if [ "${deploy_type}" == "std_app" ]; then
        proj_select_list=${git_app_list}
    elif [ "${deploy_type}" == "std_rcnn" ]; then
        proj_select_list=${git_vhost_list}
    else
        proj_select_list=${git_proj_list}
    fi
        
}

sudo apt-get update && sudo apt-get -yq install git vim
check_err "tool update fail"

parse_args $@
install_deploy_key
fetch_gitlab_src
install_host_origin_key

echo 'Fetch VDS SW Package Success.'
