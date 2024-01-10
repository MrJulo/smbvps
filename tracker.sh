#!/bin/sh

TRANSMISSION_REMOTE='/usr/bin/transmission-remote'
AUTH="$1:$2"
TRACKERLIST="/tmp/trackers.list"

trap "rm -f ./$TRACKERLIST" EXIT
wget "$3" -O "$TRACKERLIST"
sed -i '/^$/d' $TRACKERLIST
echo "[+] Got $(wc -l $TRACKERLIST) trackers"

# Add trackers to all torrents, just in caseTM
cat $TRACKERLIST | while read TRACKER; do $TRANSMISSION_REMOTE --auth=$AUTH -t all -td $TRACKER; done
