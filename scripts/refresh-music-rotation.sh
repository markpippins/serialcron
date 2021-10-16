#! bin/bash

export SCRIPT="refresh-music-rotation.sh"

frequency=60

fixFileNames() { 
    kid3-cli -c 'fromtag "%{artist} - %{album} - %{title}" 1' *.mp3 >> $LOG
    kid3-cli -c 'fromtag "%{artist} - %{album} - %{title}" 1' *.Mp3 >> $LOG
    kid3-cli -c 'fromtag "%{artist} - %{album} - %{title}" 1' *.MP3 >> $LOG
}

convertFlacsToMp3() {
    for f in *.flac; do 
        [[ ! -e "${f%.*}".mp3 ]] && flac -cd "$f" | lame -b 320 - "${f%.*}".mp3 >> $LOG
        rm -rfv "${f%.*}".flac  >> $LOG
    done
}

moveFilesToMix() {
    for f in *.mp3; do 
        mv -vf "${f%.*}".mp3 $BUFFER/mix/ >> $LOG
    done
    for f in *.Mp3; do 
        mv -vf "${f%.*}".Mp3 $BUFFER/mix/ >> $LOG
    done
    for f in *.MP3; do 
        mv -vf "${f%.*}".MP3 $BUFFER/mix/ >> $LOG
    done
}

# remove oldest media from current rotation
find $BUFFER/mix/ -type f -ctime +$frequency -exec rm -v {} \; >> $LOG
# find /media/codex/Cache/audiobooks -type f -ctime +$frequency -exec rm -v {} \; >> $LOG
# find /media/codex/Cache/books -type f -ctime +$frequency -exec rm -v {} \; >> $LOG=
# find /media/codex/Cache/comics -type f -ctime +$frequency -exec rm -v {} \; >> $LOG
# find /media/codex/Cache/movies -type f -ctime +30 -exec rm -v {} \; >> $LOG
# find /media/codex/Cache/television -type f -ctime +7 -exec rm -v {} \; >> $LOG
 
# move held music to temp
#find /media/codex/Buffer/hold/7 -type f \( -iname \*.flac -o -iname \*.mp3 \) -ctime +7 -exec mv -vf {} /$BUFFER/temp/ \;
#find /media/codex/Buffer/hold/15 -type f \( -iname \*.flac -o -iname \*.mp3 \) -ctime +15 -exec mv -vf {} /$BUFFER/temp/ \;
#find /media/codex/Buffer/hold/30 -type f \( -iname \*.flac -o -iname \*.mp3 \) -ctime +30 -exec mv -vf {} /$BUFFER/temp/ \;
#find /media/codex/Buffer/hold/45 -type f \( -iname \*.flac -o -iname \*.mp3 \) -ctime +45 -exec mv -vf {} /$BUFFER/temp/ \;

pushd $BUFFER/temp

[[ ! -e INCOMPLETE~*.* ]] && rm -vf INCOMPLETE~*.*  >> $LOG
[[ ! -e incomplete~*.* ]] && rm -vf incomplete~*.*  >> $LOG

convertFlacsToMp3
[[ ! -e *.flac ]] && rm -vf *.flac  >> $LOG
fixFileNames
moveFilesToMix
[[ ! -e *.mp3 ]] && rm -vf *.mp3  >> $LOG
[[ ! -e *.Mp3 ]] && rm -vf *.Mp3  >> $LOG
[[ ! -e *.MP3 ]] && rm -vf *.MP3  >> $LOG

popd


