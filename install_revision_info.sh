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

${0##*/} -o

    -o <REVISION_OUTPU_FILE> file to create all module version information

For example

    ./${0##*/} -o version.txt

EOM
}

get_module_revision() {
	module_list=
	revision_info=
	cd ${BASEDIR}
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
    for proj in ${git_proj_list}
    do
    	module=$(basename ${proj} | grep -o '^[^\.]*')
    	module_list="${module_list} ${module}"
    	if [ -d ${BASEDIR}/${module}/.git ]; then
            cd ${BASEDIR}/${module}
    		rev_id=$(git rev-parse HEAD)
            rev_tag=$(git show-ref --tags -d | grep ${rev_id} | sed -e 's,.* refs/tags/,,' -e 's/\^{}//')
            [ -z ${rev_tag} ] && rev_tag='(no tag)'
    		rev_branch=$(git rev-parse --abbrev-ref HEAD)
    		revision_info="${revision_info}\n${module}:\t${rev_id},\t${rev_tag},\t${rev_branch}"
            cd -
    	#echo "proj: ${proj}, basename: "$(basename ${proj} | grep -o '^[^\.]*') 
        fi
    done
   	IFS=$SAVEIFS
   	#echo ${revision_info}
	
	if [ ! -z ${rev_file} ]; then
   	    echo -e ${revision_info} > ${rev_file}
   	else
   		echo "TODO: add revision file into vcms & vds web page /version"
   	fi
}

parse_args() {
    model_list=
    optstring=o:
    while getopts $optstring opt
    do
    case $opt in
      o) rev_file=$OPTARG;;
      *) usage;
        esac
    done

    # check REVISION_OUTPU_FILE
    [ -z "${rev_file}" ] && echo "No REVISION_OUTPU_FILE is specified, default create"

}


parse_args $@
get_module_revision
