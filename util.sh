
# check return error
check_err()
{
    if [ $? -ne 0 ]; then
        echo $* >&2
        exit 2
    fi
}

install_package() {
	usage="usage:\ninstall_package /path/to/src /path/to/dest silent"
	src_path=$1
	dest_path=$2
	silent=$3
	
	[ -z ${src_path}${dest_path} ] && echo ${usge} && exit 1
	
	[ ! -d ${src_path} ] && echo "Source directory ${src_path} is not exist!" && exit 1
	
	echo "install sw from ${src_path} to ${dest_path}"
    # check install path
    yn=y
    if [ -d ${dest_path} ]; then
    	if [ ! -z ${silent} ]; then
        	read -p "install path ${dest_path} already exist, replace??[Y/n]: " yn
        fi
        [[ -z ${yn} ]] && yn=Y
        case $yn in
            [Yy]* ) rm -rf ${dest_path};;
            * ) exit;;
        esac
    fi

    mkdir -p ${dest_path}
    check_err "Can not create destion path ${dest_path}"

    cd ${src_path}
    if [ -z $INCLUDE_GIT ]; then
        cp -r ./. ${dest_path}
    else
        cp -a ./* ${dest_path} 
    fi
    cd -
    check_err "Can not copy SW package into INSTALL PATH"
}

get_mqctl_exec() {
	MQCTL_EXE=$(which rabbitmqctl)	
	if [ -z ${MQCTL_EXE} ]; then
		echo "NO rabbitmqctl Executable Exist!"
		exit 1
	fi
	echo ${MQCTL_EXE}
}

get_python_exec() {
	# check and get current python executable path 
	PYTHON_EXE=$(which python)
	if [ -z ${PYTHON_EXE} ]; then
		echo "NO PYTHON Executable Exist!"
		exit 1
	fi
	echo ${PYTHON_EXE}
}

set_daemon_default() {
    usage="set_daemon_default /etc/init.d/daemon_file"
    daemon_file=$1
    [ ! -f ${daemon_file} ] && echo "daemon file ${daemon_file} not exist." && echo ${usage} && exit 1
    sudo chmod a+x ${daemon_file}
    daemon_name=$(basename "${daemon_file}")
    update-rc.d ${daemon_name} defaults
    check_err "config daemon ${daemon_name} defaults fail"
}

install_database() {
	EXPECTED_ARGS=6
	E_BADARGS=65
	MYSQL=`which mysql`
	check_err "No mysql client command exist!"
	
	dbhost=$1
	dbname=$2
	dbuser=$3
	dbpass=$4
	dbschema=$5
    appaddr=$6
	  
	Q0="DROP DATABASE IF EXISTS ${dbname} ;"
	Q1="CREATE DATABASE ${dbname};"
	Q2="GRANT USAGE ON *.* TO ${dbuser}@${appaddr} IDENTIFIED BY '"${dbpass}"';"
	Q3="GRANT ALL PRIVILEGES ON ${dbname}.* TO ${dbuser}@${appaddr};"
	Q4="FLUSH PRIVILEGES;"
	Q5="USE ${dbname};"
	Q6="SOURCE ${dbschema};"
	SQL="${Q0}${Q1}${Q2}${Q3}${Q4}${Q5}${Q6}"
	  
	if [ $# -ne $EXPECTED_ARGS ]
	then
	  echo "Usage: $0 dbhost dbname dbuser dbpass dbschema"
	  exit $E_BADARGS
	fi
	  
	$MYSQL -u root -p -e "${SQL}"
    check_err "Database operation fail!"
}

get_local_primary_ip() {
	echo $(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
}

check_service_exist() {
	serv_name=$1
	[ -z ${serv_name} ] && echo "usage: check_service_exist serv_name" && exit 2
	if [ -z "$(sudo service ${serv_name} status 2>&1 | grep "unrecognized")" ]; then
		echo 1
	else
		echo 0
	fi
}

KEY_FILE=~/.ssh/id_rsa
ORIGIN_KEY_FILE=~/.ssh/id_rsa.origin

_install_deploy_key() {

    [ -z ${BASEDIR} ] && echo "ERR: no BASEDIR specified" && exit 2
    
    # add deploy ssh key
    mkdir -p ~/.ssh
    cp ${BASEDIR}/vds_deploy/key/deploy_rsa ${KEY_FILE}
    sudo chmod 600 ${KEY_FILE}
    echo "setup deploy ssh key for gitlab server"
    
    # add gitlab server host key to known list
    cat ${BASEDIR}/vds_deploy/key/known_hosts >> ~/.ssh/known_hosts 
}

install_deploy_key() {
    check_deploy_key
}

check_deploy_key() {
    if [ ! -f "${KEY_FILE}" ]; then
        echo "install deploy ssh key"
        _install_deploy_key
    else
        if [ ! -f "${ORIGIN_KEY_FILE}" ]; then
            echo "user ssh key exist, backup and install deploy ssh key"
            # backup origin key
            cp "${KEY_FILE}" "${ORIGIN_KEY_FILE}"
            # mv origin pub key if exist
            [ -f ${KEY_FILE}.pub ] && mv ${KEY_FILE}.pub ${KEY_FILE}.pub.origin
            _install_deploy_key
        else
            echo "WARNING: take deploy key already installed"
        fi
    fi
}

install_host_origin_key() {
    if [ -f "${ORIGIN_KEY_FILE}" ]; then
        mv "${ORIGIN_KEY_FILE}" "${KEY_FILE}"
        if [ -f ${KEY_FILE}.pub.origin ]; then
            mv ${KEY_FILE}.pub.origin ${KEY_FILE}.pub 
        fi
    else
        if [ -f ${KEY_FILE} ]; then
            rm "${KEY_FILE}"
        fi
    fi
}

