#!/usr/bin/env bash

conda update -y conda

#conda install python=3.7
conda config --add channels abreheret

#conda install -y libboost_python ## it should pick from statiskit, however if it ever becomes available in forge, than change to that one. 
conda config --add channels conda-forge

conda config --set channel_priority strict

#python=3.7

conda install -y rospkg catkin_pkg opencv ros-rosbag ros-sensor-msgs \
 ros-rosconsole ros-roslib catkin_tools libboost_python

pip install opencv-python

#mv /opt/ros/kinetic/lib/python2.7/dist-packages/cv2.so /opt/ros/kinetic/lib/python2.7/dist-packages/cv2_ros.so

mkdir /root/catkin_build_ws

cd /root/catkin_build_ws

catkin config -DPYTHON_EXECUTABLE=/opt/conda/bin/python \
-DPYTHON_INCLUDE_DIR=/opt/conda/include/python3.6m \
-DPYTHON_LIBRARY=/opt/conda/lib/libpython3.6m.so -DCMAKE_PREFIX_PATH=/opt/conda

catkin config --install

mkdir src && cd src

git clone -b noetic https://github.com/ros-perception/vision_opencv.git

sed -i -E "s/python37/python/" vision_opencv/cv_bridge/CMakeLists.txt 

cd /root/catkin_build_ws

#ln -s /usr/lib/x86_64-linux-gnu/libboost_python-py35.so /usr/lib/x86_64-linux-gnu/libboost_python3.so
#ln -s /usr/lib/x86_64-linux-gnu/libboost_python-py35.a /usr/lib/x86_64-linux-gnu/libboost_python3.a
#ln -s /opt/conda/lib/cmake/boost_python-1.70.0/boost_python-config.cmake /opt/conda/lib/cmake/boost_python-1.70.0/boost_python3-config.cmake

catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release \
-DSETUPTOOLS_DEB_LAYOUT=OFF -DCMAKE_PREFIX_PATH=/opt/conda \
--cmake-args -DPYTHON_VERSION=3.6
#-Dboost_python3_DIR=libboost_python-1.70.0-py36h39e3cac_0
