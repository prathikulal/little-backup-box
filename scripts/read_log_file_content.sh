#!/usr/bin/env bash
CONFIG_DIR=$(dirname "$0")
CONFIG="${CONFIG_DIR}/config.cfg"
source "$CONFIG"
######################################################################

while :
    do
if [ -s /home/pi/rsync_dirnFiles.log ]
then
        echo "log File is not empty"
        sourceDnF=$(tree -a "$CARD_MOUNT_POINT"| tail -1|awk '{ print "SD:"$1" SF:"$3}')
        NoOfDir=$(grep -c "cd+++++++++" /home/pi/rsync_dirnFiles.log)
        NoOfFiles=$(grep -c "f+++++++++" /home/pi/rsync_dirnFiles.log)
        message="DD:$NoOfDir DF:$NoOfFiles"
        oled r
        oled +a "Copying..."
        oled +c "$sourceDnF"
        oled +d "$message"
        #rsync -avh --info=progress2 --log-file=/home/pi/rsync_dirnFiles.log --excl$
        sudo oled s
else
        echo "log File is empty"
fi
sleep 1
done
#justcomf
