#!/usr/bin/env bash


CONFIG="/home/pi/little-backup-box/scripts/config.cfg"
source "$CONFIG"
######################################################################


if [ -s /home/pi/rsync_dirnFiles.log ]
then
        echo "File is not empty"
else
        echo "File is empty"
fi

NoOfDir=$(grep -c "cd+++++++++" /home/pi/rsync_dirnFiles.log)
NoOfFiles=$(grep -c "f+++++++++" /home/pi/rsync_dirnFiles.log)
oled r
message="DR:$NoOfDir FL:$NoOfFiles"
oled r
oled +d "$message"
#rsync -avh --info=progress2 --log-file=/home/pi/rsync_dirnFiles.log --excl$


sudo oled s
############################################################


sync
oled r
