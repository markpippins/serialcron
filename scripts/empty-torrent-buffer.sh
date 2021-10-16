#! /bin/bash
# fires when torrent completes

export SCRIPT="empty-torrent-buffer"

pushd /media/vitriol-seagate_5/new/

find . -iname "ETRG.*" -iname *.nfo -delete;
find . -iname "sample.*" -delete;
find . -iname "*.sample" -delete;
# find . -iname "*.sub" -delete;
find . -iname "*.idx" -delete;
find . -iname "*.jpg" -delete;
find . -iname "*.jpeg" -delete;
find . -iname "*.url" -delete;
# find . -iname "*.srt" -delete;
find . -iname "*.txt" -delete;
find . -iname "*.nfo" -delete;

find . -iname "*.flv" -exec mv -vf {} . \; 
find . -iname "*.mpg" -exec mv -vf {} . \;
find . -iname "*.mp4" -exec mv -vf {} . \;
find . -iname "*.mkv" -exec mv -vf {} . \;
find . -iname "*.wmv" -exec mv -vf {} . \;
find . -iname "*.avi" -exec mv -vf {} . \;
find . -iname "*.m4v" -exec mv -vf {} . \;

find . -type d -empty -delete;

python /home/codex/python/rename_2.py >> $LOG

# find . -iname "*.flv" -exec mv -vf {} ../new/ \; 
# find . -iname "*.mpg" -exec mv -vf {} ../new/ \;
# find . -iname "*.mp4" -exec mv -vf {} ../new/ \;
# find . -iname "*.mkv" -exec mv -vf {} ../new/ \;
# find . -iname "*.wmv" -exec mv -vf {} ../new/ \;
# find . -iname "*.avi" -exec mv -vf {} ../new/ \;
# find . -iname "*.m4v" -exec mv -vf {} ../new/ \;

popd
