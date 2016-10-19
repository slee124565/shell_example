#!/bin/bash -x
  
export LC_ALL=C

source ./util.sh

usage()
{
more <<EOM

Usage:

${0##*/} -h <APP_ADDR> -d <DB_ADDR> -u <DB_USER> -p <DB_PWD> -i <DB_NAME> -f <DB_SCHEMA_FILE>

    -h <APP_ADDR> DB client App internal IP address

    -d <DB_ADDR> database server internal IP address

    -u <DB_USER> database login username for VDS

    -p <DB_PWD> database login password for VDS

    -i <DB_NAME> database instance name for VDS

    -f <DB_SCHEMA_FILE> VDS database tables schema creation script


For example
	install VDS_API database
    ./${0##*/} -h 172.17.0.9 -d 127.0.0.1 -u vds -p vds -i vds -f ./vds_api/vds_api.sql

	install VCMS database
    ./${0##*/} -h 172.17.0.9 -d 127.0.0.1 -u vcms -p vcms -i vcms -f ./vds_vcms/vds_vcms.sql

EOM
}

parse_args() {
    model_list=
    optstring=h:d:u:p:i:f:
    while getopts $optstring opt
    do
    case $opt in
      h) app_addr=$OPTARG;;
      d) host_db=$OPTARG;;
      u) db_user=$OPTARG;;
      p) db_passwd=$OPTARG;;
      i) db_name=$OPTARG;;
      f) db_schema=$OPTARG;;
      *) usage;
        esac
    done

    # check DB_ADDR
    [ -z "${app_addr}" ] && echo "No APP_ADDR is specified!" && usage && exit 1

    # check DB_ADDR
    [ -z "${host_db}" ] && echo "No DB_ADDR is specified!" && usage && exit 1

    # check DB_USER
    [ -z "${db_user}" ] && echo "No DB_USER is specified!" && usage && exit 1

    # check DB_PWD
    [ -z "${db_passwd}" ] && echo "No DB_PWD is specified!" && usage && exit 1

    # check DB_NAME
    [ -z "${db_name}" ] && echo "No DB_NAME is specified!" && usage && exit 1

    # check DB_SCHEMA_FILE
    [ -z "${db_schema}" ] && echo "No DB_SCHEMA_FILE is specified!" && usage && exit 1
    [ ! -f "${db_schema}" ] && echo "DB_SCHEMA_FILE ${db_schema} not exist!" && usage && exit 1

}


parse_args $@
install_database ${host_db} ${db_name} ${db_user} ${db_passwd} ${db_schema} ${app_addr}
check_err "install ${db_name} database fail!"

echo "${db_name} database installation success."
