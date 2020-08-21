FROM nvidia/cuda:10.1-base

ENV DEBIAN_FRONTEND noninteractive

ARG PYTHON_VERSION=3.6
RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         vim \
         ca-certificates \
         libjpeg-dev \
         libpng-dev &&\
     rm -rf /var/lib/apt/lists/*


RUN curl -o ~/mini.sh -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
     chmod +x ~/mini.sh && \
     ~/mini.sh -b -p /opt/conda && \
     rm ~/mini.sh


RUN  /opt/conda/bin/conda install -y python=$PYTHON_VERSION numpy pyyaml scipy ipython mkl mkl-include cython typing && \
     /opt/conda/bin/conda install -y -c pytorch magma-cuda101 && \
     /opt/conda/bin/conda clean -ya

ENV PATH /opt/conda/bin:$PATH
     #RUN pip install ninja
     # This must be done before pip so that requirements.txt is available
WORKDIR /opt

#not the latest. we might need to do some version matching here
##RUN git clone --recursive https://github.com/mysablehats/pytorch.git

RUN git clone --recursive https://github.com/pytorch/pytorch
RUN cd pytorch && TORCH_CUDA_ARCH_LIST="3.5 5.2 6.0 6.1 7.0+PTX" TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
     CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" \
     pip install -v .

RUN git clone https://github.com/pytorch/vision.git && cd vision && pip install -v .

WORKDIR /workspace
RUN chmod -R a+w /workspace


############# needs sshd and ros with python3 running (copy what I did for fr machine)

#### ROS stuff

RUN apt-get -y update && apt-get install lsb-core --no-install-recommends -y

RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

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
     python-rosdep \
     python-rosinstall \
     python-rosinstall-generator \
     python-wstool \
     && apt-get clean && rm -rf /tmp/* /var/tmp/*

     # some more ros stuff
RUN rosdep init && rosdep update


     # to get ssh working for the ros machine to be functional: (adapted from docker docs running_ssh_service)
RUN mkdir /var/run/sshd \
     && echo 'root:ros_ros' | chpasswd \
     && sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
     && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
ADD requirements_tch.txt /root/

RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc

ENV ROS_MASTER_URI=http://SATELLITE-S50-B:11311

     #add my snazzy banner
ADD banner.txt /root/
     ### try to run jupyter so we can do some coding...
RUN pip install jupyter
     ##jupyter notebook --port=8888 --no-browser --ip=172.28.5.31 --allow-root

ADD scripts/entrypoint.sh /root/
ENTRYPOINT ["/root/entrypoint.sh"]
     ###needs the catkin stuff as well.
