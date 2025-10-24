sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y     git    zip    unzip    openssh-client    libsuitesparse-dev    libceres-dev    ninja-build     protobuf-compiler    python3-rosdep    python3-rosinstall    python3-rosinstall-generator    python3-wstool    build-essential    clang    cmake    google-mock    libboost-all-dev    libcairo2-dev    libcurl4-openssl-dev    libeigen3-dev    libgflags-dev    libgoogle-glog-dev    liblua5.2-dev    lsb-release    python3-sphinx    libgmock-dev    stow    ros-noetic-tf2-sensor-msgs    ros-noetic-geographic-msgs    libgeographic-dev    libsdl-image1.2    libsdl-image1.2-dev    libsdl1.2-dev  liborocos-bfl-dev    shc 
rm /tmp/resources -rf
cp ./resources /tmp/resources -rf
cd /tmp/resources 

# 编译安装cartographer的依赖abseil
unzip abseil-cpp-20211102.0.zip && \
    cd abseil-cpp-20211102.0 && \
    mkdir build && \
    cd build && \
    cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_INSTALL_PREFIX=/usr/local/stow/absl \
    .. && \
    ninja 
sudo ninja install && \
    cd /usr/local/stow && \
    sudo stow absl && \
    sudo ldconfig

# 编译安装cartographer的依赖ceres
cd /tmp/resources && \
    tar -xvf protobuf-3.4.1.tar.gz && \
    cd protobuf-3.4.1 && \
    mkdir build && \
    cd build && \
    cmake -G Ninja \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -Dprotobuf_BUILD_TESTS=OFF \
    ../cmake &&\
    ninja 
sudo ninja install

# 编译安装cartographer
cd /tmp/resources && \
    unzip cartographer-master.zip && \
    cd cartographer-master && \
    mkdir build && \
    cd build && \
    cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release && \
    ninja
sudo ninja install && \
   sudo  ldconfig 
