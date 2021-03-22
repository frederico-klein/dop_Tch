FROM pytorch/pytorch:latest

ARG PYTHON_VERSION=3.6

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV NOTVISIBLE "in users profile"

ADD scripts/ros_key.sh /root/
ADD scripts/ros.sh /root/
ADD requirements_ros.txt /root/
ADD requirements_tch.txt /root/
ADD banner.txt /etc/

RUN apt-get update && apt-get install -y --fix-missing \
      vim \
      ca-certificates \
      gnupg2 \
      git \
      curl \
      lsb-core \
      build-essential\
      openssh-server\
      python3-pip \
      tar\
      python3-opencv \
      && apt-get clean && rm -rf /tmp/* /var/tmp/* && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd \
     && echo 'root:ros_ros' | chpasswd \
     && sed -i 's/[#\s]*PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
     && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
     && sed -i 's/[#\s]*Banner none/Banner \/etc\/banner.txt/' /etc/ssh/sshd_config \
     && echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

RUN pip3 install pip --upgrade \
    && pip3 install -r /root/requirements_tch.txt

RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list \
    && /root/ros_key.sh \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
    && pip3 install -r /root/requirements_ros.txt \
    && rosdep init && rosdep update

#RUN /root/ros.sh $PYTHON_VERSION melodic

ENV ROS_VERSION=melodic
RUN apt-get -y update && mkdir -p /root/ros_catkin_ws/src \
    && rosinstall_generator ros_comm sensor_msgs image_transport common_msgs cv_bridge --rosdistro $ROS_VERSION --deps --wet-only > /root/ros_catkin_ws/$ROS_VERSION-ros_comm-wet.rosinstall
RUN vcs import /root/ros_catkin_ws/src --workers 1 < /root/ros_catkin_ws/$ROS_VERSION-ros_comm-wet.rosinstall
RUN cd /root/ros_catkin_ws \
    && rosdep install --from-paths src --ignore-src -y

RUN cd /root/ros_catkin_ws \
    && catkin build -DCATKIN_ENABLE_TESTING=0 -DCMAKE_BUILD_TYPE=Release -DPYTHON_VERSION=3.6

# RUN cd /root/ros_catkin_ws &&\
#   ~/ros_catkin_ws/src/catkin/bin/catkin_make_isolated --install \
#     -DCMAKE_BUILD_TYPE=Release \
#     -DSETUPTOOLS_DEB_LAYOUT=OFF \
#     --cmake-args -DPYTHON_VERSION=$PYTHON_VERSION\
#       -DPYTHON_EXECUTABLE=/usr/bin/python3

# RUN cd /root/ros_catkin_ws &&\
#   ~/ros_catkin_ws/src/catkin/bin/catkin_make_isolated --install \
#     -DCMAKE_BUILD_TYPE=Release \
#     -DSETUPTOOLS_DEB_LAYOUT=OFF \
#     --cmake-args -DPYTHON_VERSION=$PYTHON_VERSION\
#       -DPYTHON_EXECUTABLE=/usr/bin/python3 \
#       -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m \
#       -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so && \
#   echo "source ~/ros_catkin_ws/install_isolated/setup.bash" >>  ~/.bashrc

##this is hacky, fix properly.
# RUN mkdir -p /usr/local/nvidia/lib/ && \
#   ln -s /opt/conda/lib/libcudart.so.11.0  /usr/local/nvidia/lib/libcudart.so.10.1

ADD scripts/entrypoint.sh /root/
#WORKDIR /workspace
ENTRYPOINT ["/root/entrypoint.sh"]
