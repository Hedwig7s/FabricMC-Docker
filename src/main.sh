#!/usr/bin/env bash

#* All Arguments Supportet
#MC_VERSION="1.19.2"                # Minecraft Server version
#MC_EULA="true"                     # Minecraft's Eula
#MC_RAM_XMS="1536M"                 # Preallocated RAM
#MC_RAM_XMX="2048M"                 # Max RAM
#MC_PRE_JAR_ARGS=""                 # ARG's before the JAR
#MC_POST_JAR_ARGS=""                # ARG's after the JAR
#MC_URL_ZIP_SERVER_FIILES=""        # Zip for all of the server files. Gets merged with the current Server Folder
#FABRIC_INSTALLVER="1.0.1"          # Fabric Installer Version
#FABRIC_VERSION=""                  # Fabric Loader Version
#FORCE_INSTALL=""                   # Force the installation of the Fabric jar

MCDIR="/home/server"
MCJAR="$MCDIR/fabric-server-launch.jar"
MCTEMP="/server_tmp"
MCARGS="-Xms$MC_RAM_XMS -Xmx$MC_RAM_XMX --add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 $MC_PRE_JAR_ARGS -jar $MCJAR $MC_POST_JAR_ARGS --nogui"     # -Xms<> -Xmx<> <args> -jar <jar> <args>
: "${FABRIC_INSTALLVER:=1.0.1}"

cd $MCDIR

echo "###############################################"
echo "#   FabricMC - `date`   #"
echo "###############################################"
echo 
echo "Initializing..."

function GetFile {
    [ -n "$1" ] && curl -s -C - -o "$2" "$1" || return 1
    [ $? -eq 0 ] && echo "Downloaded $1" && return 0 ||\
                    echo "Could not get $1" && return 1
}

# Download the file even if it exits with "curl -C -" to be sure that it is complete
if [[ ! -e $MCJAR || -n $FORCE_INSTALL ]]; then
    echo "Downloading and installing Fabric..."
    GetFile "https://maven.fabricmc.net/net/fabricmc/fabric-installer/$FABRIC_INSTALLVER/fabric-installer-$FABRIC_INSTALLVER.jar" "$MCDIR/fabric-installer.jar"
    java -jar "$MCDIR/fabric-installer.jar" server ${MC_VERSION:+-mcversion "$MC_VERSION"} -dir "$MCDIR" -downloadMinecraft ${FABRIC_VERSION:+-loader "$FABRIC_VERSION"}
    if [[ $? -eq 0 ]]; then
        rm "$MCDIR/fabric-installer.jar"
    fi
fi

# Getting Server files from user
GetFile "$MC_URL_ZIP_SERVER_FIILES" "$MCDIR/ZIP_SERVER_FILES"
[ $? -eq 0 ] && unar "$MCDIR/ZIP_SERVER_FILES" -f

# Accepting EULA
[ "$MC_EULA" == "true" ] && echo "Setting EULA to true" && printf "eula=true" > $MCDIR/eula.txt

echo "Initialization finished!"
echo
echo "#################### Info #####################"
echo " MC_VERSION: $MC_VERSION"
echo " MC_EULA: $MC_EULA"
echo " MC_RAM_XMS: $MC_RAM_XMS"
echo " MC_RAM_XMX: $MC_RAM_XMX"
echo " MC_PRE_JAR_ARGS: $MC_PRE_JAR_ARGS"
echo " MC_POST_JAR_ARGS: $MC_POST_JAR_ARGS"
echo " MC_URL_ZIP_SERVER_FIILES: $MC_URL_ZIP_SERVER_FIILES"
echo "###############################################"
echo
echo "Start command: java $MCARGS"
echo "Starting Server..."
echo

# Starting the server
exec java $MCARGS