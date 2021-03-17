#!/bin/bash
source /root/ros_catkin_ws/devel/setup.bash
source /workspace/catkin_ws/devel/setup.bash
export ROS_HOSTNAME=lavine.local

exec "$@"
