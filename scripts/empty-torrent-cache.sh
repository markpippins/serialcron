#! /bin/bash
# fire when torrent completes

export SCRIPT="empty-torrent-cache"
params="-rzmKvp --ignore-errors --remove-source-files --exclude=.directory --verbose --progress"
tempdir=$BUFFER/transmission/temp

[[ ! -d $CACHE ]] && error "Cache folder unavailable, $SCRIPT aborting..." && return
[[ ! -e $MEDIA ]] && error "$MEDIA unavailable, files remain in Cache" && return

find $tempdir -iname */sample/*.* -delete
find $tempdir -iname sample.* -delete
find $tempdir -iname sample.txt -delete
find $tempdir -iname *.nfo -delete
find $tempdir -iname ETRG.* -delete
find $tempdir -type d -iname sample -delete
find $tempdir -iname *torrent*.txt -delete
find $tempdir -iname *read\ me*.txt -delete
find $tempdir -iname *please\ read*.txt -delete
find $tempdir -iname *HDTV*.txt -delete
find $tempdir -iname *Web-DL*.txt -delete
find $tempdir -iname *please*.txt -delete
find $tempdir -iname *read-me*.txt -delete
find $tempdir -iname RARBG.txt -delete
find $tempdir -type d -iname *torrent* -delete
find $tempdir -iname TSV.* -delete
find $tempdir -iname Downloaded\ from* -delete 

# debug "moving audio files..."
# [[ -f *.mp3 ]] && mv -v *.mp3 .audio/
# [[ -f *.flac ]] && mv -v *.flac .audio/
# [[ -d audio/complete ]] && rsync $params audio/complete/ $AUDIO/music/incoming/ >> $LOG
rsync $params --exclude=downloading audio/ $CACHE/overflow/audio/music/ >> $SYNC

# debug "moving video files..."
# rsync $params $CACHE/incoming/video/ $VIDEO/incoming/ >> $LOG
rsync $params $CACHE/incoming/television/ $TELEVISION/ >> $SYNC
rsync $params $CACHE/incoming/movies/ $MOVIES/ >> $SYNC

#debug "moving comics files..."
rsync $params $CACHE/incoming/comics/ $COMICS/ >> $SYNC

debug "moving books..."
rsync $params $CACHE/incoming/books/ $BOOKS/ >> $SYNC$

debug "moving magazines..."
rsync $params $CACHE/incoming/magazines/ $MEDIA/magazines/ >> $SYNC

debug "moving pictures..."
rsync $params $CACHE/incoming/pics/ $PICTURES/ >> $SYNC

debug "moving audiobooks..."
rsync $params $CACHE/incoming/audiobooks/ $MEDIA/audio/audiobooks/ >> $SYNC

debug "clearing empty folders..."
find $CACHE -type d -empty -delete
