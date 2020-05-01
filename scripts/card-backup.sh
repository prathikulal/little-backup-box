#!/usr/bin/env bash

# Author: Dmitri Popov, dmpop@linux.com

#######################################################################
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################
# my stabel version

#CONFIG_DIR=$(dirname "$0")
#CONFIG="${CONFIG_DIR}/config.cfg"
CONFIG="/home/pi/little-backup-box/scripts/config.cfg"
source "$CONFIG"

# Set the ACT LED to heartbeat
sudo sh -c "echo heartbeat > /sys/class/leds/led0/trigger"

# Shutdown after a specified period of time (in minutes) if no device is connected.
#sudo shutdown -h $SHUTD "Shutdown is activated. To cancel: sudo shutdown -c"
if [ $DISP = true ]; then
    oled r
    oled +b "Shutdown active"
    oled +c "Insert storage"
    sudo oled s
fi

# Wait for a USB storage device (e.g., a USB flash drive)
STORAGE=$(ls /dev/* | grep "$STORAGE_DEV" | cut -d"/" -f3)
while [ -z "${STORAGE}" ]
do
    sleep 1
    STORAGE=$(ls /dev/* | grep "$STORAGE_DEV" | cut -d"/" -f3)
done

# When the USB storage device is detected, mount it
mount /dev/"$STORAGE_DEV" "$STORAGE_MOUNT_POINT"

# Set the ACT LED to blink at 1000ms to indicate that the storage device has been mounted
sudo sh -c "echo timer > /sys/class/leds/led0/trigger"
sudo sh -c "echo 1000 > /sys/class/leds/led0/delay_on"

# Cancel shutdown
sudo shutdown -c

# If display support is enabled, notify that the storage device has been mounted
if [ $DISP = true ]; then
    oled r
    oled +b "  Storage OK"
    oled +c "   Insert"
    oled +d "card reader..."
    sudo oled s
fi

# Wait for a card reader or a camera
# takes first device found
CARD_READER=($(ls /dev/* | grep "$CARD_DEV" | cut -d"/" -f3))
until [ ! -z "${CARD_READER[0]}" ]
  do
  sleep 1
  CARD_READER=($(ls /dev/* | grep "$CARD_DEV" | cut -d"/" -f3))
done

# If the card reader is detected, mount it and obtain its UUID
mount /dev"/${CARD_READER[0]}" "$CARD_MOUNT_POINT"

# Set the ACT LED to blink at 500ms to indicate that the card has been mounted
sudo sh -c "echo 500 > /sys/class/leds/led0/delay_on"


####my code
STORAGE_AV_SIZE_HR=$(df -kh |grep "$STORAGE_MOUNT_POINT"|awk '{print $4}') #Available storage size in human readable format
STORAGE_AV_SIZE=$(df -k |grep "$STORAGE_MOUNT_POINT"|awk '{print $4}') #Available storage size in BYTES
CARD_DATA_SIZE_HR=$(df -kh |grep "$CARD_MOUNT_POINT"|awk '{print $3}') # Size of data present in card in human readable format
CARD_DATA_SIZE=$(df -k |grep "$CARD_MOUNT_POINT"|awk '{print $3}') # Size of data present in card in BYTES
#sleep 5
#####


# If display support is enabled, notify that the card has been mounted
if [ $DISP = true ]; then
    oled r
    oled +b "Card reader OK"
    #oled +c "Working..."
    sudo oled s
#my code start
    sleep 3
    oled r
    oled +b "Storage size"
    oled +c "Remaining:"
    oled +d "$STORAGE_AV_SIZE_HR"
    sudo oled s
    sleep 3
    oled r
    oled +b "Card data size:"
    oled +d "$CARD_DATA_SIZE_HR"
    sudo oled s
    sleep 3
    #oled r
#    oled +a "Copying..."
#    sudo oled s
#### my code end
fi

#my code start
if [ $STORAGE_AV_SIZE -lt $CARD_DATA_SIZE ]
 then
#if [$STORAGE_AV_SIZE le $CARD_DATA_SIZE]; then
  echo "Not enough storage available"
  oled r
  oled +b "Not enough"
  oled +c "storage available"
  oled +d "Shutdown..."
  sudo oled s
  sync
  oled r
  exit
  #shutdown -h now
fi
  echo "Storage available"
  oled r
  oled +b " Storage"
  oled +c "available"
  sudo oled s
  sleep 2
#  oled r
#  oled +a "Copying..."
#  sourceDnF=$(tree -a "$CARD_MOUNT_POINT"| tail -1|awk '{ print "D:"$1" F:"$3}')
  #message="DR:$NoOfDir FL:$NoOfFiles"
#  oled +c "$sourceDnF"
#  sudo oled s
#  sleep 1

#my code ends

# Create  a .id random identifier file if doesn't exist
cd "$CARD_MOUNT_POINT"
if [ ! -f *.id ]; then
    random=$(echo $RANDOM)
    touch $(date -d "today" +"%Y%m%d%H%M")-$random.id
fi
ID_FILE=$(ls *.id)
ID="${ID_FILE%.*}"
cd

# Set the backup path
BACKUP_PATH="$STORAGE_MOUNT_POINT"/"$ID"
ST_SZ_BEFR_CP=$(df -k |grep "$STORAGE_MOUNT_POINT"|awk '{print $3}')
echo "Storage size before copy $ST_SZ_BEFR_CP"
$(touch /home/pi/rsync_dirnFiles.log;cat /dev/null> /home/pi/rsync_dirnFiles.log)
# Perform backup using rsync
rsync -avh --info=progress2 --log-file=/home/pi/rsync_dirnFiles.log --exclude "*.id" "$CARD_MOUNT_POINT"/ "$BACKUP_PATH"
if [ "$?" -eq "0" ]
then
  #echo "rsync was success"
  $(cat /dev/null> /home/pi/rsync_dirnFiles.log)

  ST_SZ_AFTR_CP=$(df -k |grep "$STORAGE_MOUNT_POINT"|awk '{print $3}')
  echo "Storage size after copy $ST_SZ_AFTR_CP"
  sleep 1 # added as margin for file read log file script

else
  $(cat /dev/null> /home/pi/rsync_dirnFiles.log)
  sleep 1
  echo "Error while running rsync"
  oled r
  oled +b "Error while copy"
  oled +c "Shutdown"
  sudo oled s
  #clear log file of display

  #shutdown -h now
  exit
fi

# If display support is enabled, notify that the backup is complete

if [ $DISP = true ]; then
    SIZE_DIFF=$(`expr $ST_SZ_AFTR_CP - $ST_SZ_BEFR_CP`)
    echo "Storage difference after copy $SIZE_DIFF"
    oled r
    oled +a "Backup complete"
    oled +b "HDD byte delta:"
    oled +c "$SIZE_DIFF"
    dataFrmRsync=$(tail -n 7  /home/pi/little-backup-box.log |grep sent|awk '{print $2}')
    message="Rsync:$dataFrmRsync"
    oled +d "$message"
    #messageMC=$SIZE_DIFF 1235658985
    #oled +c "Shutdown"
    sudo oled s
fi
# Shutdown
sync
if [ $DISP = true ]; then
    oled r
fi
#shutdown -h now
