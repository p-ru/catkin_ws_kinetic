#!/bin/bash

#run this script inside the docker container

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

genjava_message_artifacts --verbose -p dji_srvs std_msgs

echo "=========================="
echo "publishToMavenLocal"
echo "=========================="
cd ~/catkin_ws_kinetic/build/dji_srvs
./gradlew publishToMavenLocal


# Source directory
SRC_DIR="$HOME/.m2/repository/org/ros/rosjava_messages"

# Destination directory
DEST_DIR="$HOME/catkin_ws_kinetic"

# Make sure source exists
if [ ! -d "$SRC_DIR" ]; then
  echo "Source directory $SRC_DIR does not exist."
  exit 1
fi

# Copy recursively, preserving attributes
cp -r "$SRC_DIR" "$DEST_DIR"
echo "Copied $SRC_DIR to $DEST_DIR"


