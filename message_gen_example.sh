#!/bin/bash

# 1. Source ROS Kinetic environment
source /opt/ros/kinetic/setup.bash

# 2. Add your current 'src' folder to the ROS Package Path
# This tells ROS where to find 'dji_srvs'
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$(pwd)/src

mkdir -p ~/.gradle
cat > ~/.gradle/init.gradle << 'EOF'
allprojects {
    configurations.all {
        resolutionStrategy.eachDependency { details ->
            if (details.requested.group == 'org.apache.commons' &&
                details.requested.name.startsWith('com.springsource.org.apache.commons')) {

                def realArtifact = details.requested.name
                        .replace('com.springsource.org.apache.commons.', 'commons-')
                def realVersion = [
                        'codec' : '1.15',
                        'io'    : '2.11.0',
                        'lang'  : '2.6'
                ][realArtifact - 'commons-']

                details.useTarget "commons-${realArtifact - 'commons-'}:${realArtifact}:${realVersion}"
            }
        }
    }
}
EOF

export ROS_MAVEN_REPOSITORY=https://raw.githubusercontent.com/rosjava/rosjava_mvn_repo/master
export ROS_MAVEN_REPOSITORY2=https://repo1.maven.org/maven2

# Clean build to prevent permission errors
rm -rf build

# Generate artifacts
# Now that ROS_PACKAGE_PATH is set, this should see 'dji_srvs'
genjava_message_artifacts --verbose -p dji_srvs std_msgs

echo "=========================="
echo "publishToMavenLocal"
echo "=========================="

# Check if directory exists before cd
if [ -d "build/dji_srvs" ]; then
    cd build/dji_srvs
    ./gradlew publishToMavenLocal
else
    echo "ERROR: build/dji_srvs directory was not generated."
    echo "Double check that the 'dji_srvs' folder exists in your 'src' directory."
    exit 1
fi

# Source directory
SRC_DIR="/root/.m2/repository/org/ros/rosjava_messages"

# Destination directory
DEST_DIR="/root/catkin_ws_kinetic"

# Make sure source exists
if [ ! -d "$SRC_DIR" ]; then
  echo "Source directory $SRC_DIR does not exist."
  exit 1
fi

# Copy recursively, preserving attributes
cp -r "$SRC_DIR" "$DEST_DIR"
echo "Copied $SRC_DIR to $DEST_DIR"