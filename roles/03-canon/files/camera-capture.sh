#!/bin/bash
## edit the variables to your needs
UPDATE_INTERVAL=5
MOUNTPOINT="/tmp/canon"
CAMERA_FOLDER=$MOUNTPOINT/store_*/DCIM/*CANON/
OUTPUT="/home/john/Pictures/camera-sync"
USER=john_doe
HOST=my-great-computer.example.lan
RSYNC_OPTIONS="-r --delete -e ssh $CAMERA_FOLDER $USER@$HOST:$OUTPUT"

mkdir -p $MOUNTPOINT

function run {
	gphotofs ${MOUNTPOINT} -o allow_other
	rsync $RSYNC_OPTIONS
	if [ $? -eq 0 ]
	then
          echo "[CANON-SYNC]$(date):  synced to $USER@$HOST:$OUTPUT"
	else
          echo "[CANON-SYNC]$(date):  ERROR WITH rsync"
	fi
	fusermount -u ${MOUNTPOINT}
	sleep $UPDATE_INTERVAL
}

while true; do
	run
done
