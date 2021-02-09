FROM pytorch/pytorch:latest

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ARG PYTHON_VERSION=3.6

RUN apt-get update && apt-get install -y --no-install-recommends \
         vim \
         ca-certificates \
         gnupg2 \
         lsb-core \
         && apt-get clean && rm -rf /tmp/* /var/tmp/* && rm -rf /var/lib/apt/lists/*

RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list
ADD scripts/ros_key.sh /root/
RUN /root/ros_key.sh

RUN apt-get -y update
RUN apt-get install -y --fix-missing \
      git \
      curl \
      python3-pip \
      openssh-server\
      tar\
      python3-rosdep \
      python3-opencv \
      python3-rosinstall-generator \
      python3-vcstool \
      && apt-get clean && rm -rf /tmp/* /var/tmp/* && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
RUN rosdep init && rosdep update
ADD scripts/ros.sh /root/
RUN /root/ros.sh $PYTHON_VERSION melodic

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
# RUN mkdir -p /usr/local/nvidia/lib/ && \
#   ln -s /opt/conda/lib/libcudart.so.11.0  /usr/local/nvidia/lib/libcudart.so.10.1

ADD scripts/entrypoint.sh /root/
WORKDIR /workspace
ENTRYPOINT ["/root/entrypoint.sh"]
