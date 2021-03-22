#!/bin/sh
#this file needs to be built procedurally

set -e
echo "10.0.0.8  scitos" >> /etc/hosts
echo "10.0.0.239 SATELLITE-S50-B" >> /etc/hosts
echo "172.28.5.2 tsn_denseflow" >> /etc/hosts
echo "history -s /tmp/start.sh " >> /root/.bashrc
echo "history -s wandb login " >> /root/.bashrc
echo "history -s jupyter notebook --port=8888 --no-browser --ip=`hostname -I` --allow-root " >> /root/.bashrc
echo "history -s git clone https://github.com/amreelab/esa_project.git " >> /root/.bashrc
echo "history -s  catkin_make -DPYTHON_VERSION=3.6 " >> /root/.bashrc

find /root/dop_tch/workspace -maxdepth 1 -mindepth 1 -type d -exec ln -vs "{}" /workspace/ ';'
ln -s /mnt/share/misc /workspace/misc

#bash  /root/face_recognition/catkin_ws.sh
service ssh restart
cat /etc/banner.txt
export ROS_MASTER_URI=http://lavine.local:11311
. /workspace/catkin_ws/devel/setup.bash
exec "$@"
