#!/bin/bash -x 
  
export LC_ALL=C

FILE_PATH=$(echo $(cd $(dirname "$0") && pwd -P)/$(basename "$0"))
BASEDIR=$(dirname "$(dirname "${FILE_PATH}")")
echo "BASEDIR: ${BASEDIR}"

source ./util.sh

check_pip_version() {
    PIP_EXEC=$(which pip)
    PIP_VER=$(${PIP_EXEC} --version | awk '{print $2}')
    if [ "${PIP_VER}" == "8.1.2" ]; then
        echo 1
    else
        echo 0
    fi
}

install_setuptool_pip() {
    
    if [ $(check_pip_version) -eq 0 ]; then
        # install python setup tool
        echo "install python setuptool ..."
        cd ${BASEDIR}
        sudo wget https://bootstrap.pypa.io/ez_setup.py -O - | python
        check_err "setuptool install fail"
        cd -
        
        # install pip
        echo "install pip-8.1.2 ...."
        sudo wget -nc -P ${BASEDIR} https://pypi.python.org/packages/e7/a8/7556133689add8d1a54c0b14aeff0acb03c64707ce100ecd53934da1aa13/pip-8.1.2.tar.gz
        tar -xzvf ${BASEDIR}/pip-8.1.2.tar.gz -C ${BASEDIR}
        cd ${BASEDIR}/pip-8.1.2
        sudo python setup.py install
        check_err "pip-8.1.2 install fail"
        cd -  
    else
        echo "pip already exist, skip."
    fi
}

install_req_lib() {
    APT_REPO_DEFAULT=/etc/apt/sources.list.default
    if [ ! -f ${APT_REPO_DEFAULT} ]; then
        sudo cp /etc/apt/sources.list ${APT_REPO_DEFAULT}
    fi

	sudo apt-get update && sudo apt-get -yq install python python-dev wget zip
	check_err "python install fail"

    install_setuptool_pip
    	
    sudo apt-get -yq install libncurses-dev python-mysqldb libmysqlclient-dev libjpeg-dev software-properties-common
    check_err "install pre-request lib fail!"
    
}

install_opencv_tool() {
	# build tool and lib setup
	sudo apt-get -yq install build-essential cmake libgtk2.0-dev pkg-config python-numpy libavcodec-dev libavformat-dev libswscale-dev
    check_err "opencv build tool and lib setup fail"
}

make_install_opencv() {    
    # check if opencv already exist
    #if [ -f "/usr/local/lib/libopencv_core.so" ]; then
    #    echo "Warning: opencv already exist, skip install opencv"
    #    return 0
    #fi

    # unzip opencv 
    unzip -o opencv-2.4.9.zip -d ${BASEDIR}
    check_err "unzip opencv fail"

    cd ../opencv-2.4.9 
    mkdir -p release
    cd release

    cmake \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DWITH_FFMPEG=ON \
        -DWITH_CUDA=OFF ..
    check_err "cmake opencv lib fail"

    make -j 4
    check_err "make opencv lib fail"

    sudo make install
    check_err "install opencv lib fail"

    # add cv2.so to site-package
    ln -s /usr/local/lib/python2.7/dist-packages/cv2.so /usr/local/lib/python2.7/site-packages/
    
    # solve import cv2 issue: libdc1394 error: Failed to initialize libdc1394
    sudo ln /dev/null /dev/raw1394
}

install_ffmpeg() {
	# check ffmpeg exist
	if [ ! -z "$(which ffmpeg)" ]; then
		echo "warning: ffmpeg already exist, skip install ffmpeg"
		return 0
	fi

	sudo add-apt-repository -y ppa:mc3man/trusty-media
	check_err "add-apt-repository fail"
	
	sudo apt-get update
	#apt-get -y dist-upgrade
	apt-get -yq install ffmpeg
	check_err "install ffmpeg fail"
}

install_python_matplotlib() {
    # check python-matplotlib exist
    if [ -d "/usr/lib/pymodules/python2.7/matplotlib" ]; then
        echo "warning: python-matplotlib already exist, skip install"
        return 0
    fi

    sudo apt-get -yq install python-matplotlib
    check_err "install python matplotlib fail"
}

install_caffe() {
    # check caffe exist
    if [ -d /usr/local/lib/caffe ]; then
        echo "warning: caffe already exist, skip install"
        return 0
    fi
    
    # execute caffe instal script
    cp ./install_caffe.sh ../
    cd ..
    ./install_caffe.sh
    check_err "install caffe fail"
    cd -
    
}

# deploy type: std_app, std_vhost, default is allinone
deploy_type=$1

install_req_lib
if [ "${deploy_type}" == "std_app" ]; then
	install_ffmpeg
	install_python_matplotlib
	install_opencv_tool
	make_install_opencv # fail on my mac docker environment
	
	sudo pip install -r $(dirname ${FILE_PATH})/vds_requirement.txt
	check_err "pip install vds requirement fail"
	
elif [ "${deploy_type}" == "std_rcnn" ]; then
	install_python_matplotlib
	install_caffe

	sudo pip install -r $(dirname ${FILE_PATH})/vhost_requirement.txt
	check_err "pip install vhost requirement fail"

else # all_in_one installation
	install_ffmpeg
	install_python_matplotlib
	install_caffe
	install_opencv_tool
	make_install_opencv # fail on my mac docker environment

	sudo pip install -r $(dirname ${FILE_PATH})/all_requirement.txt
	check_err "pip install vds/vhost requirement fail"
fi

