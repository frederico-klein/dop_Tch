#!/bin/bash
source /root/ros_catkin_ws/devel/setup.bash
WORKSPACEFILE=/workspace/catkin_ws/devel/setup.bash
set -e
if [ ! -f "${WORKSPACEFILE}" ]
then
  pushd /workspace/catkin_ws/
  catkin_make -DPYTHON_VERSION=3.6
  popd
fi
source /workspace/catkin_ws/devel/setup.bash
export ROS_MASTER_URI=http://lavine.local:11311
exec "$@"
