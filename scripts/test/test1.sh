tree -a /media/card | tail -1

NoOfDir=grep -c "cd+++++++++" /tmp/rgrggrr.txt
NoOfFiles=grep -c "f+++++++++" /tmp/rgrggrr.txt

sourceDnF= tree -a /media/card/MUSIC | tail -1|awk '{ print "D:"$1"\tF:"$3}'

 truncate -s 0 /tmp/rsync_dirnFiles.log



#CONFIG_DIR=$(dirname "$0")
CONFIG="/home/pi/little-backup-box/scripts/config.cfg"
source "$CONFIG"
######################################################################
NoOfDir=$(grep -c "cd+++++++++" /tmp/rsync_dirnFiles.log)
NoOfFiles=$(grep -c "f+++++++++" /tmp/rsync_dirnFiles.log)
oled r
message="DR:$NoOfDir FL:$NoOfFiles"
oled +d "$message"
#rsync -avh --info=progress2 --log-file=/tmp/rsync_dirnFiles.log --excl$


sudo oled s
############################################################


sync
oled r
