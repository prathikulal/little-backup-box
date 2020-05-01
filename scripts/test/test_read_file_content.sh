#!/usr/bin/env bash
#CONFIG_DIR=$(dirname "$0")
#CONFIG="${CONFIG_DIR}/config.cfg"
CONFIG="/home/pi/little-backup-box/scripts/config.cfg"
#/home/pi/little-backup-box/scripts/config.cfg
source "$CONFIG"
######################################################################

          copyPercentage=$(tail -n 7  /home/"$USER"/little-backup-box.log |grep %|tail -n 1|awk '{print $3}')
        messageA="Copying... $copyPercentage"
          copySize=$(tail -n 7 /home/"$USER"/little-backup-box.log |grep %|tail -n 1|awk '{print $2}')
          ElapseTime=$(tail -n 7 /home/"$USER"/little-backup-box.log |grep %|tail -n 1|awk '{print $5}')
        messageB="$copySize $ElapseTime"
          copySpeed=$(tail -n 7 /home/"$USER"/little-backup-box.log |grep %|tail -n 1|awk '{print $4}')
        messageC="Speed: $copySpeed"
          CPUtemp=$(vcgencmd measure_temp|awk '{split($0,a,"=");print a[2]}')
          CPUload=$(w|head -n 1|awk '{print $9}'|awk '{split($0,a,",");;print a[1]}')
        messageD="$CPUtemp CPU:$CPUload"
        oled r
        oled +a "$messageA"
        oled +b "$messageB"
        oled +c "$messageC"
        oled +d "$messageD"
        sudo oled s
        oled r
