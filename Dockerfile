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
         libpng-dev &&\
     rm -rf /var/lib/apt/lists/*

#TODO: ros not working with python3. needs fixing.

#### ROS stuff

ADD requirements_ros.txt /root/
RUN pip3 install --trusted-host pypi.python.org -r /root/requirements_ros.txt && \
    pip2 install --trusted-host pypi.python.org -r /root/requirements_ros.txt && \
    python -m pip install --trusted-host pypi.python.org -r /root/requirements_ros.txt

ADD requirements_opencv.txt /root/
RUN python -m pip install --upgrade pip && \
    python -m pip install --trusted-host pypi.python.org -r /root/requirements_opencv.txt

RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list
ADD scripts/ros_key.sh /root/
RUN /root/ros_key.sh

##after adding the key we need to update it again!

RUN apt-get -y update
RUN apt-get install -y --fix-missing \
     python3-pip \
     python-pip \
     openssh-server\
     libssl-dev \
     lsb-core \
     python-sh \
     tar\
     libboost-all-dev \
     ros-melodic-ros-base \
     libcv-dev \
     python-catkin-pkg \
     python-opencv \
     python-rosdep \
     python-rosinstall \
     python-rosinstall-generator \
     python-wstool \
     && apt-get clean && rm -rf /tmp/* /var/tmp/*

     # some more ros stuff
RUN rosdep init && rosdep update
ADD scripts/ros.sh /root/
RUN /root/ros.sh
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc

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
