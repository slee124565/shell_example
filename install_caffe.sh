#!/bin/bash

###########################################################
#
#
# Faster R-CNN
#
#
###########################################################

#-------------------------------------------------------------------------------------------------
# @inproceedings{renNIPS15fasterrcnn,
#    Author = {Shaoqing Ren and Kaiming He and Ross Girshick and Jian Sun},
#    Title = {Faster {R-CNN}: Towards Real-Time Object Detection with Region Proposal Networks},
#    Booktitle = {Advances in Neural Information Processing Systems ({NIPS})},
#    Year = {2015}
# }
#-------------------------------------------------------------------------------------------------

dateformat="+%a %b %-eth %Y %I:%M:%S %p %Z"
starttime=$(date "$dateformat")
starttimesec=$(date +%s)

curdir=$(cd `dirname $0` && pwd)

logfile="$curdir/install-caffe.log"
rm -f $logfile

# Logger simples
log(){
     timestamp=$(date +"%Y-%m-%d %k:%M:%S")
     echo "$timestamp $1"
     echo "$timestamp $1" >> $logfile 2>&1
}

# Starting setup the faster-rcnn
echo "Setting up Faster-RCNN..."
log "Setting up Faster-RCNN..."

# Get dependencies
log "Get dependencies"
sudo apt-get update
sudo apt-get -yq install bc cmake curl gcc-4.8 g++-4.8 gcc-4.8-multilib g++-4.8-multilib gfortran git unzip
sudo apt-get -yq install libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libboost-all-dev libhdf5-serial-dev liblmdb-dev libjpeg62 libfreeimage-dev libatlas-base-dev pkgconf protobuf-compiler libopenblas-dev libgflags-dev libgoogle-glog-dev

# Install OpenBlas
log "install OpenBlas"
git clone git://github.com/xianyi/OpenBLAS
cd OpenBLAS/
make FC=gfortran
sudo make PREFIX=/usr/local/ install
cd ..

# Use gcc-4.8
update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-4.8 30
update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-4.8 30
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 30
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 30

# Install Glog and Gflags
log "install Glog"
cd /home
wget --quiet https://google-glog.googlecode.com/files/glog-0.3.3.tar.gz
tar zxvf glog-0.3.3.tar.gz
cd glog-0.3.3
./configure
make -j$(nproc)
make install -j$(nproc)
cd ..
rm -rf glog-0.3.3.tar.gz
ldconfig

log "install Gflags"
cd /home
wget --quiet https://github.com/schuhschuh/gflags/archive/master.zip
unzip master.zip
cd gflags-master
mkdir build
cd build
export CXXFLAGS="-fPIC"
cmake ..
make VERBOSE=1
make  -j$(nproc)
make install -j$(nproc)
cd ../..
rm master.zip

# Setup the faster-rcnn
log "Setup the faster-rcnn"
cd /home
git clone --recursive https://github.com/ShaoqingRen/faster_rcnn.git
cd faster_rcnn/external/caffe/

# Modify Makefile.config setting
log "Modify Makefile.config setting"
cp Makefile.config.example Makefile.config
sed -i '8c CPU_ONLY := 1' Makefile.config
sed -i '33c BLAS := open' Makefile.config
sed -i '81c USE_PKG_CONFIG := 1' Makefile.config

# Modify upgrade_proto.cpp
log "Add layers"
cd src/caffe/util/
sed -i '919a case V1LayerParameter_LayerType_RESHAPE:\
    return "Reshape";\
  case V1LayerParameter_LayerType_ROIPOOLING:\
    return "ROIPooling";\
  case V1LayerParameter_LayerType_SMOOTH_L1_LOSS:\
    return "SmoothL1Loss";' upgrade_proto.cpp
cd ../../../

# Build caffe
log "Build caffe..."
make
make test
log "make sure all test are passed"
make runtest

log "caffe install successful"


endtime=$(date "$dateformat")
endtimesec=$(date +%s)

elapsedtimesec=$(expr $endtimesec - $starttimesec)
ds=$((elapsedtimesec % 60))
dm=$(((elapsedtimesec / 60) % 60))
dh=$((elapsedtimesec / 3600))
displaytime=$(printf "%02d:%02d:%02d" $dh $dm $ds)
log "elapsed: $displaytime\n"
