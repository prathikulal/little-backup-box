#!/usr/bin/env bash
#CONFIG_DIR=$(dirname "$0")
#CONFIG="${CONFIG_DIR}/config.cfg"
CONFIG="/home/pi/little-backup-box/scripts/config.cfg"
source "$CONFIG"
######################################################################

while :
    do
if [ -s /home/pi/rsync_dirnFiles.log ]
then
        #echo "log File is not empty"

        #old code start
        #sourceDnF=$(tree -a "$CARD_MOUNT_POINT"| tail -1|awk '{ print "SD:"$1" SF:"$3}')
        #  NoOfDir=$(grep -c "cd+++++++++" /home/pi/rsync_dirnFiles.log)
        #  NoOfFiles=$(grep -c "f+++++++++" /home/pi/rsync_dirnFiles.log)
        #  message="DD:$NoOfDir DF:$NoOfFiles"
        # old code ends
        #oled r
        #oled +a "Copying..."
        #oled +c "$sourceDnF"
        #oled +d "$message"

#/home/pi/little-backup-box.log
 #tail -n 7  /home/pi/little-backup-box.log |grep %|tail -n 1|awk '{print $3}'
 #vcgencmd measure_temp|awk '{split($0,a,"=");print a[2]}'
 #$(w|head -n 1|awk '{print $8}'|awk '{split($0,a,",");;print a[1]}') #CPU load 1min average
#       Copying... 100%
#       589.51M  0:01:19
#       Speed: 17.11MB/s
#       53.7'C CPU:0.15
          copyPercentage=$(tail -n 7  /home/pi/little-backup-box.log |grep %|tail -n 1|awk '{print $3}')
        messageA="Copying... $copyPercentage"
          copySize=$(tail -n 7 /home/pi/little-backup-box.log |grep %|tail -n 1|awk '{print $2}')
          ElapseTime=$(tail -n 7 /home/pi/little-backup-box.log |grep %|tail -n 1|awk '{print $5}')
        messageB="$copySize $ElapseTime"
          copySpeed=$(tail -n 7 /home/pi/little-backup-box.log |grep %|tail -n 1|awk '{print $4}')
        messageC="Speed: $copySpeed"
          CPUtemp=$(vcgencmd measure_temp|awk '{split($0,a,"=");print a[2]}')
          CPUload=$(w|head -n 1|awk '{print $9}'|awk '{split($0,a,",");;print a[1]}')
        messageD="$CPUtemp CPU:$CPUload"
        oled r
        oled +a "$messageA"
        oled +b "$messageB"
        oled +c "$messageC"
        oled +d "$messageD"
        #rsync -avh --info=progress2 --log-file=/home/pi/rsync_dirnFiles.log --excl$
        sudo oled s
else
        echo "log File is empty"
fi
sleep 1
done
#justcomf
