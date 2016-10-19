#!/bin/bash
  
export LC_ALL=C

source ./util.sh

install_nginx() {
	# check nginx exist
	NGINX_EXE=$(which nginx)
	if [ ! -z ${NGINX_EXE} ]; then
		echo "nginx already installed, skip install process."
		return
	fi
	
	# install nginx
	sudo apt-get -yq install nginx
	check_err "install nginx fail"

}

config_nginx() {
    NGINX_CONFIG_FILE=/etc/nginx/nginx.conf
    NGINX_CONFIG_DEFAULT=/etc/nginx/nginx.conf.default

    # backup/restore origin nginx.conf
    if [ ! -f ${NGINX_CONFIG_DEFAULT} ]; then
        cp ${NGINX_CONFIG_FILE} ${NGINX_CONFIG_DEFAULT}
    else
        cp ${NGINX_CONFIG_DEFAULT} ${NGINX_CONFIG_FILE}
    fi

    num=$(sed -n '/sendfile on/ =' ${NGINX_CONFIG_FILE})
    if [ -z ${num} ] || [ ${num} -lt 1 ]; then
        echo "error in config ${NGINX_CONFIG_FILE}" && exit 2
    fi

    # add    client_body_buffer_size 8m;
    sed -i "${num}i\\   client_body_buffer_size 8m;" ${NGINX_CONFIG_FILE}

    # add     client_max_body_size 32m;
    sed -i "${num}i\\   client_max_body_size 32m;" ${NGINX_CONFIG_FILE}

    # nginx reload
    sudo service nginx reload
    check_err "nginx reload fail"
}

install_uwsgi() {
	# check uwsgi exist
	UWSGI_EXE=$(which uwsgi)
	if [ ! -z ${UWSGI_EXE} ]; then
		echo "uwsgi already installed, skip install process."
		return
	fi

	# install uwsgi
	sudo pip install uwsgi
	check_err "install nginx fail"
	
	# config uwsgi
	config_uwsgi
	
	# set uwsgi as startup service
	sudo update-rc.d uwsgi defaults
	check_err "set uwsgi as startup service fail"
	
	# start uwsgi
	sudo service uwsgi start
	check_err "start uwsgi fail"
}

config_uwsgi() {

	# create uwsgi log directory
	sudo mkdir -p /var/log/uwsgi/apps
	
	# create uwsgi emperor directory
	sudo mkdir -p /etc/uwsgi/apps-enabled
	
	# create uwsgi daemon script
	UWSGI_EXE=$(which uwsgi)
	UWSGI_DAEMON_FILE=/etc/init.d/uwsgi
	
    cat >${UWSGI_DAEMON_FILE} <<EOL
#!/bin/bash 
#${UWSGI_DAEMON_FILE}

### BEGIN INIT INFO
# Provides:          FLH
# Required-Start:    \$remote_fs \$syslog
# Required-Stop:     \$remote_fs \$syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: uwsgi startup script
# Description:       This service is used to manage a daemon
### END INIT INFO


case "\$1" in
    start)
        echo "Starting uWSGI"
        exec ${UWSGI_EXE} --emperor /etc/uwsgi/apps-enabled &
        ;;
    stop)
        echo "Stopping uWSGI"
        killall uwsgi
        ;;
    *)
        echo "Usage: ${UWSGI_DAEMON_FILE} start|stop"
        exit 1
        ;;
esac

exit 0	
EOL
    	check_err "create uwsgi daemon script ${UWSGI_DAEMON_FILE} fail!"

	sudo chmod a+x ${UWSGI_DAEMON_FILE}
}

install_req_lib() {
    sudo apt-get update && sudo apt-get -yq install python python-dev python-pip psmisc
    check_err "install pre-request lib fail!"
}

install_req_lib
install_nginx
config_nginx
install_uwsgi

