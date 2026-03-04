#!/bin/bash

XAUTH=/tmp/.docker.xauth
# (Xauthority setup remains the same)
xauth_list=$(xauth nlist :0 | tail -n 1 | sed -e 's/^..../ffff/')
if [ -n "$xauth_list" ]; then
    echo "$xauth_list" | xauth -f "$XAUTH" nmerge -
else
    touch "$XAUTH"
fi
chmod a+r "$XAUTH"

# Run Docker container as ROOT
# Changes made:
# 1. Removed -u $(id -u):$(id -g)
# 2. Removed -v /etc/passwd and -v /etc/group
# 3. Changed volume mount to map host folder directly to /root/catkin_ws_kinetic
docker run --rm \
    --privileged \
    --gpus all \
    --network=host \
    --ipc=host \
    --env "ACCEPT_EULA=Y" \
    --env "PRIVACY_CONSENT=Y" \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --env="XAUTHORITY=$XAUTH" \
    -v "$XAUTH:$XAUTH" \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v /$(pwd)/:/root/catkin_ws_kinetic/ \
    -w /root/catkin_ws_kinetic \
    -it kinetic_rosjava