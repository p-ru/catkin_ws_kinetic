#!/bin/bash

XAUTH=/tmp/.docker.xauth
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "Preparing Xauthority data..."

# (Your Xauthority setup remains the same)
xauth_list=$(xauth nlist :0 | tail -n 1 | sed -e 's/^..../ffff/')
if [ -n "$xauth_list" ]; then
    echo "$xauth_list" | xauth -f "$XAUTH" nmerge -
else
    touch "$XAUTH"
fi
chmod a+r "$XAUTH"

# Run Docker container with added passwd and group mounts
docker run \
    --privileged \
    --gpus all \
    --network=host \
    --ipc=host \
    --env "ACCEPT_EULA=Y" \
    --env "PRIVACY_CONSENT=Y" \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --env="XAUTHORITY=$XAUTH" \
    -u $(id -u):$(id -g) \
    -v "$XAUTH:$XAUTH" \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v /etc/passwd:/etc/passwd:ro \
    -v /etc/group:/etc/group:ro \
    -v /home/droneproject/catkin_ws_kinetic/:/home/droneproject/catkin_ws_kinetic/ \
    -w /root/catkin_ws_kinetic \
    -it kinetic_rosjava