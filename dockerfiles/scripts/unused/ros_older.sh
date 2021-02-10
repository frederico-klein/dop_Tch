#!/usr/bin/env bash
#from http://wiki.ros.org/$ROS_VERSION/Installation/Source with minor adaptations to make it compile
PYTHON_VERSION=$1
ROS_VERSION=$2
UBUNTU_DISTRO=$(lsb_release -sc)
export ROS_PYTHON_VERSION=3

apt-get -y update
mkdir -p ~/ros_catkin_ws/src
pushd ~/ros_catkin_ws
cp ../install_skip.sh ./
if [ -f "$ROS_VERSION-ros_comm-wet.rosinstall" ]
then
	echo "installation file already exists. using this one"
else
	rosinstall_generator ros_comm sensor_msgs image_transport common_msgs cv_bridge --rosdistro $ROS_VERSION --deps --wet-only > $ROS_VERSION-ros_comm-wet.rosinstall
fi
vcs import src < $ROS_VERSION-ros_comm-wet.rosinstall
apt-get -y update
##cake recipe!
pip3 install -U -f https://extras.wxpython.org/wxPython4/extras/linux/gtk3/ubuntu-18.04 wxPython

./install_skip `rosdep check --from-paths src --ignore-src | grep python | sed -e "s/^apt\t//g" | sed -z "s/\n/ /g" | sed -e "s/python/python3/g"`
rosdep install --from-paths src --ignore-src -y --skip-keys="`rosdep check --from-paths src --ignore-src | grep python | sed -e "s/^apt\t//g" | sed -z "s/\n/ /g"`"

find . -type f -exec sed -i 's/\/usr\/bin\/env[ ]*python/\/usr\/bin\/env python3/g' {} +

#rosdep install --from-paths src --ignore-src --rosdistro $ROS_VERSION -y  --os=ubuntu:$UBUNTU_DISTRO

popd
