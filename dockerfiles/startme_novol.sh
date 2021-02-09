#!/usr/bin/env bash

# nvidia-docker became docker --gpus all now and probably the NV_GPU flag doesn't work anymore. But maybe someone might want to still use nvidia-docker2 package, so this script needs to become slightly more generic.

##todo: add check to see if /mnt/share exists
##todo add check to see if expect is installed
##todo: fix expect syntax. it works in some machines but not others.

#Tthis was horrible and it took me long to fix
##todo: does it make sense to mount a remote host?
DOCKERMACHINEIP=172.28.6.31
DOCKERMACHINENAME=tch_new
MACHINEHOSTNAME=torch_machine4
#THISWSPATH=/workspace
#DOCKERFILE=docker/pytorch/ ## standard should be .
#BUILDINDIR=$PWD/pytorch ##standard should be $PWD
DOCKERFILE=.
BUILDINDIR=$PWD
#export NV_GPU=1
if [ -z "$PWD" ]
then
  echo "??"
else
  while true; do
    {
    #echo "doing nothing"
    OLDDIR=$PWD
    cd $BUILDINDIR
    echo "skip!!!!"
    #docker build -t $DOCKERMACHINENAME $DOCKERFILE
    #nvidia-docker build --no-cache -t $DOCKERMACHINENAME .
    cd $OLDDIR
    } ||
    {
    echo "something went wrong..." &&
    break
    }
  echo "STARTING ROS PYTORCH ROS DOCKER..."

  ISTHERENET=`docker network ls | grep br0`
  if [ -z "$ISTHERENET" ]
  then
    echo "docker network br0 not up. creating one..."
    docker network create \
      --driver=bridge \
      --subnet=172.28.0.0/16 \
      --ip-range=172.28.6.0/24 \
      --gateway=172.28.6.254 \
      br0
  else
    echo "found br0 docker network."
  fi
  #nvidia-docker run --rm -it -p 8888:8888 -h $MACHINEHOSTNAME --network=br0 --ip=$DOCKERMACHINEIP $DOCKERMACHINENAME #bash

#  nvidia-docker run --rm -it -u root -p 8888:8888 -p 222:22 -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $THISVOLUMENAME:/catkin_ws -h $MACHINEHOSTNAME --network=br0 --ip=$DOCKERMACHINEIP $DOCKERMACHINENAME bash # -c "jupyter notebook --port=8888 --no-browser --ip=$DOCKERMACHINEIP --allow-root &" && bash -i
   # the k40 is useless with cuda 10.1
   # -v tubvolume0://workspace/workspace \
   docker run --gpus '"device=0"' --rm -it -u root --privileged \
   -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /mnt/share:/mnt/share \
    -h $MACHINEHOSTNAME --network=br0 --ip=$DOCKERMACHINEIP $DOCKERMACHINENAME bash # -c "jupyter notebook --port=8888 --no-browser --ip=172.28.5.4 --allow-root &" && bash -i
   #nvidia-docker run --rm -it -u root -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $THISVOLUMENAME:$THISWSPATH -v /mnt/share:/mnt/share -h $MACHINEHOSTNAME --network=br0 --ip=$DOCKERMACHINEIP $DOCKERMACHINENAME bash # -c "jupyter notebook --port=8888 --no-browser --ip=172.28.5.4 --allow-root &" && bash -i


  ## if I add this with -v I can't catkin_make it with entrypoint...
  #-v /temporal-segment-networks/catkin_ws:$PWD/catkin_ws/src
  #
  #docker volume rm $THISVOLUMENAME
  break
  done
fi
