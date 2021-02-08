FROM pytorch/pytorch:latest

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ARG PYTHON_VERSION=3.6

RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         vim \
         ca-certificates \
         gnupg2 \
         libjpeg-dev \
         lsb-core \
         libpng-dev

RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list
ADD scripts/ros_key.sh /root/
RUN /root/ros_key.sh

RUN apt-get -y update
RUN apt-get install -y --fix-missing \
     python3-pip \
     openssh-server\
     libssl-dev \
     lsb-core \
     tar\
     libboost-all-dev \
     libopencv-dev \
     python3-catkin-pkg \
     python3-opencv \
     python3-rosdep \
     python3-rosinstall \
     python3-rosinstall-generator \
     python3-vcstool \
     python3-empy \
     python3-coverage \
     python3-setuptools \
     python3-defusedxml \
     && apt-get clean && rm -rf /tmp/* /var/tmp/* && rm -rf /var/lib/apt/lists/*

ADD requirements_opencv.txt /root/
RUN python -m pip install --upgrade pip && \
    pip3 install --trusted-host pypi.python.org -r /root/requirements_opencv.txt && \
    python -m pip install --trusted-host pypi.python.org -r /root/requirements_opencv.txt

ADD requirements_ros.txt /root/
RUN pip3 install --trusted-host pypi.python.org -r /root/requirements_ros.txt && \
    python -m pip install --trusted-host pypi.python.org -r /root/requirements_ros.txt

     # some more ros stuff
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
RUN rosdep init && rosdep update
#RUN apt-get -y update ##remove or rosdep will not work!
ADD scripts/ros.sh /root/
RUN /root/ros.sh $PYTHON_VERSION melodic

#Imanidiot
RUN apt-get -y update
RUN cd /root/ros_catkin_ws &&\
    rosdep install --from-paths src --ignore-src --rosdistro $ROS_VERSION -y  --os=ubuntu:$UBUNTU_DISTRO
#RUN apt-get install -y --fix-missing \
    # librosconsole-bridge-dev
    # librosconsole-bridge0d
    # python3-nose
    # libpoco-dev
    # libtinyxml2-6
    # libtinyxml2-dev
    # python3-lz4
    # liblz4-dev

## we have python2, but we are making python3 default.
# RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
# RUN cd /root/ros_catkin_ws &&\
#   ~/ros_catkin_ws/src/catkin/bin/catkin_make_isolated --install \
#     -DCMAKE_BUILD_TYPE=Release \
#     -DSETUPTOOLS_DEB_LAYOUT=OFF \
#     --cmake-args -DPYTHON_VERSION=$PYTHON_VERSION\
#       -DPYTHON_EXECUTABLE=/usr/bin/python3 \
#       -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m \
#       -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so && \
#   echo "source ~/ros_catkin_ws/install_isolated/setup.bash" >>  ~/.bashrc

# to get sshd working: (adapted from docker docs running_ssh_service)
#add my snazzy banner
ADD banner.txt /etc/

RUN mkdir /var/run/sshd \
     && echo 'root:ros_ros' | chpasswd \
     && sed -i 's/[#\s]*PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
     && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
     && sed -i 's/[#\s]*Banner none/Banner \/etc\/banner.txt/' /etc/ssh/sshd_config

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

ADD requirements_tch.txt /root/
RUN pip3 install pip --upgrade \
    && pip3 install -r /root/requirements_tch.txt

##this is hacky, fix properly.
RUN mkdir -p /usr/local/nvidia/lib/ && \
  ln -s /opt/conda/lib/libcudart.so.11.0  /usr/local/nvidia/lib/libcudart.so.10.1

ADD scripts/entrypoint.sh /root/
WORKDIR /workspace
ENTRYPOINT ["/root/entrypoint.sh"]
