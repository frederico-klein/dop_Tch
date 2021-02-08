#!/usr/bin/env bash
#from http://wiki.ros.org/$ROS_VERSION/Installation/Source with minor adaptations to make it compile

PYTHON_VERSION=$1
ROS_VERSION=$2
UBUNTU_DISTRO=$(lsb_release -sc)

mkdir -p ~/ros_catkin_ws
pushd ~/ros_catkin_ws
#cp /root/fix.py ./

if [ -f "$ROS_VERSION-ros_comm-wet.rosinstall" ]
then
	echo "installation file already exists. using this one"
else
	rosinstall_generator ros_comm sensor_msgs image_transport common_msgs cv_bridge --rosdistro $ROS_VERSION --deps --wet-only > $ROS_VERSION-ros_comm-wet.rosinstall
fi

### this needs to be python2.7 and not conda's 3.6 version
# export OLDPATH=$PATH
# export PATH=/usr/bin:$PATH
#python2.7 fix.py

#wstool init -j`nproc` src $ROS_VERSION-ros_comm-wet-fixed.rosinstall
wstool init -j`nproc` src $ROS_VERSION-ros_comm-wet.rosinstall

rosdep install --from-paths src --ignore-src --rosdistro $ROS_VERSION -y  --os=ubuntu:$UBUNTU_DISTRO

cd  /usr/lib/x86_64-linux-gnu/
ln -s libboost_python-py35.so libboost_python3.so
~/ros_catkin_ws/src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release -DSETUPTOOLS_DEB_LAYOUT=OFF --cmake-args -DPYTHON_VERSION=$PYTHON_VERSION\
-DPYTHON_EXECUTABLE=/usr/bin/python3 \
-DPYTHON_INCLUDE_DIR=/usr/include/python3.6m \
-DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so


###oh, i changed from 3.5 to 3.6 so this might break as well...

#ln -s "libzstd.so.1.3.1" "libzstd.so"


#last but not the least, we want to source devel.bash
echo "source ~/ros_catkin_ws/install_isolated/setup.bash" >>  ~/.bashrc

# export PATH=$OLDPATH
popd
