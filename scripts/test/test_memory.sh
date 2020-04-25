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

#CONFIG_DIR=$(dirname "$0")
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
    oled +b "Storage OK"
    oled +c "Card reader..."
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
STORAGE_AV_SIZE=$(df -k |grep "$STORAGE_MOUNT_POINT"|awk '{print $4}') #Available storage size in human readable format
CARD_DATA_SIZE_HR=$(df -kh |grep "$CARD_MOUNT_POINT"|awk '{print $3}') # Size of data present in card in human readable format
CARD_DATA_SIZE=$(df -k |grep "$CARD_MOUNT_POINT"|awk '{print $3}') # Size of data present in card in human readable format
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
if [$STORAGE_AV_SIZE -lt $CARD_DATA_SIZE]
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
  oled +b "Storage available"
  sudo oled s

sync
if [ $DISP = true ]; then
    oled r
fi
#shutdown -h now
