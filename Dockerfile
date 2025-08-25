FROM osrf/ros:kinetic-desktop-full

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive
 

# Update and install required packages
RUN apt-get update && \
    apt-get install -y ros-kinetic-genjava nano gedit wget unzip &&\
    apt-get install --only-upgrade ros-kinetic-* &&\
    apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

RUN echo "source /opt/ros/kinetic/setup.bash" >> /root/.bashrc




