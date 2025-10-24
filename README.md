# tooker_docker

快速上手：

为了方便没用过的dokcer的同学。这里快速理解docker4个概念，可以用如下方式去理解:  

- Dockerfile 如何生成一个镜像(Image)
- Image 镜像 类似一个系统的.iso文件
- Container 容器 类似用镜像(.iso文件)创建了的一个VM虚拟机
- Volume 卷 类似移动硬盘，可以挂载到Container虚拟机上

镜像-容器的关系，可以理解为类和实例的关系:

```c++
Image container1 = new Image.
```

这样一个镜像可以创建多个容器。



1. 安装docker

2. 打开cmd，cd到该项目目录下。用当前目录下的Dockerfile创建容器镜像，并给这个镜像起一个名字tooker_noetic。
  

```shell
docker build -t tooker_noetic .
```


   如果下载osrf/ros:noetic-desktop-full失败，请开梯子。如果还是失败，请开梯子，并先执行下面的pull命令,再去执行上面build命令

   ```shell
   docker pull docker.io/osrf/ros:noetic-desktop-full
   ```

3. 创建一个Volume，放入我们的项目代码

   ```shell
   docker volume create tooker5_standard
   ```

4. 用tooker_noetic创建一个容器，给这个容器起名字，例如叫 tooker_noetic_container_1, 同时挂在我们的volume到/home/netlab。该命令因为-it，所以会进入该容器的命令行。

```sh
docker run -it --name tooker_noetic_container_1  -v tooker5_standard:/home/netlab/tooker5_standard/  tooker_noetic 
docker run -it --name xungu_nav  -v ssh:/home/xungu/.ssh/ -p 9787:9787 ubuntu_humble 
```

5. 再重新开一个windows的cmd.我们需要将代码，从windows复制到我们的容器中。windows下的cmd命令

   ```shell
   docker cp d:\tooker5_standard.tar.gz tooker_noetic_container_1:/home/netlab/tooker5_standard/
   ```
   
6. 最后,在我们的容器的shell中。解压代码，然后编译项目

   ```sh
   windows_cmd:  docker exec -it tooker_noetic_container_1 /bin/bash
   cd /home/netlab/tooker5_standard
   tar vxf tooker5_standard.tar.gz -C .
   cd tooker5_ws
   catkin_make install
   ```

