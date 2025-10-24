FROM osrf/ros:noetic-desktop-full

# 设置使用国内阿里云的源
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
RUN sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# 使用bash来替代默认的sh( 因为source 命令不在sh中生效。等结束时候，恢复)
RUN mv /bin/sh /bin/sh_bak && ln -s /bin/bash /bin/sh

# 更新
RUN apt-get update && apt-get upgrade -y

# 安装一些其他使用到的工具
RUN apt-get install -y \    
    git \
    zip \
    unzip \
    openssh-client \
    libsuitesparse-dev \
    libceres-dev \
    ninja-build \    
    protobuf-compiler \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    build-essential \
    clang \
    cmake \
    google-mock \
    libboost-all-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libeigen3-dev \
    libgflags-dev \
    libgoogle-glog-dev \
    liblua5.2-dev \
    lsb-release \
    python3-sphinx \
    libgmock-dev \
    stow \
    ros-noetic-move-base-flex \
    ros-noetic-teb-local-planner \
    ros-noetic-tf2-sensor-msgs \
    ros-noetic-geographic-msgs \
    libgeographic-dev \
    libsdl-image1.2 \
    libsdl-image1.2-dev \
    libsdl1.2-dev \
    liborocos-bfl-dev \
    shc 
    #  \ ros-noetic-people-msgs

# 删除缓存
RUN rm -rf /var/lib/apt/lists/*

# 复制资源
COPY resources /tmp/resources 

# 编译安装cartographer的依赖abseil
RUN cd /tmp/resources && \    
    unzip abseil-cpp-20211102.0.zip && \
    cd abseil-cpp-20211102.0 && \
    mkdir build && \
    cd build && \
    cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_INSTALL_PREFIX=/usr/local/stow/absl \ 
    .. && \
    ninja && \
    ninja install && \
    cd /usr/local/stow && \
    stow absl && \
    ldconfig
# 编译安装cartographer的依赖ceres
RUN cd /tmp/resources && \
    tar -xvf protobuf-3.4.1.tar.gz && \
    cd protobuf-3.4.1 && \
    mkdir build && \
    cd build && \
    cmake -G Ninja \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -Dprotobuf_BUILD_TESTS=OFF \
    ../cmake &&\
    ninja && \
    ninja install
# 编译安装cartographer
RUN cd /tmp/resources && \
    unzip cartographer-master.zip && \
    cd cartographer-master && \
    mkdir build && \
    cd build && \
    cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release && \
    ninja && \
    ninja install && \
    ldconfig 

# 编译 cartographer_ros
RUN cd /tmp/resources && \
    unzip cartographer_ros-master.zip && \
    mkdir -p /tmp/resources/cartographer_ws/src && \
    mv cartographer_ros-master /tmp/resources/cartographer_ws/src/cartographer_ros && \
    cd /tmp/resources/cartographer_ws 
RUN source /opt/ros/noetic/setup.bash && \
    cd /tmp/resources/cartographer_ws && \
    catkin_make_isolated --use-ninja --install-space /opt/cartographer_ros --install
# 删除资源
RUN rm -rf /tmp/resources

# 设置用户名和密码
ENV USER_NAME=netlab
ENV USER_PASSWORD=netlab
# 创建用户
RUN useradd -ms /bin/bash $USER_NAME && echo $USER_NAME:$USER_PASSWORD |chpasswd
# 将USER添加到root
RUN usermod -aG sudo $USER_NAME
RUN echo "$USER_NAME ALL=(ALL) ALL" >> /etc/sudoers
RUN echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 创建用户的工作目录
RUN mkdir -p /home/$USER_NAME
# 设置用户的目录权限
RUN chown -R $USER_NAME:$USER_NAME /home/$USER_NAME

# 设置ros环境变量 到.bashrc文件中
RUN echo 'source /opt/ros/noetic/setup.bash' >> /home/$USER_NAME/.bashrc 
RUN echo 'source /opt/cartographer_ros/install_isolated/setup.bash' >> ~/.bashrc 

# 将sh恢复
RUN rm /bin/sh && mv /bin/sh_bak /bin/sh

# 切换到新用户
USER $USER_NAME
WORKDIR /home/$USER_NAME
