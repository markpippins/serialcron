#! /bin/bash
# move buffered audio to media drive

export SCRIPT="empty-slsk-buffer"
params="-rvz --progress --ignore-existing --exclude=.directory --remove-source-files"

[[ ! -d $BUFFER ]] && error "Buffer folder unavailable, $SCRIPT aborting..." && return
# [[ ! -d $CACHE ]] && error "Cache folder unavailable, $SCRIPT aborting..." && return
[[ ! -d $MEDIA ]] && error "Media folder unavailable, $SCRIPT aborting..." && return

debug "emptying buffer..." 
soulseek=$BUFFER/soulseek/complete


debug "moving external downloads..." 
rsync $params $CACHE/incoming/audio/complete/ $soulseek/ >> $LOG

# get rid of uneccesary files
find $soulseek -type f \( -iname \*.m3u -o -iname \*.sfv -o -iname \*.nfo -o -iname \*.cue -o -iname \*.txt \) -delete >> $LOG

# copy new media files to temp for portable mix
find $soulseek -type f \( -iname \*.flac -o -iname \*.mp3 \) -exec cp -vn {} /$BUFFER/temp/ \; >> $LOG
find $soulseek -type f \( -iname \*.cbr -o -iname \*.cbz \) -exec cp -vn {} /$CACHE/comics/ \; >> $LOG

# curated downloads
[[ -d $soulseek/albums/ ]] && rsync $params $soulseek/albums/ $MEDIA/audio/music/albums/ >> $SYNC
[[ -d $soulseek/compilations/ ]] && rsync $params $soulseek/compilations/ $MEDIA/audio/music/compilations/ >> $SYNC
[[ -d $soulseek/random/ ]] && rsync $params $soulseek/random/ $MEDIA/audio/music/random/ >> $SYNC
[[ -d $soulseek/comics/ ]] && rsync $params $soulseek/comics/ $MEDIA/comics/ >> $SYNC
[[ -d $soulseek/books/ ]] && rsync $params $soulseek/books/ $MEDIA/comics/ >> $SYNC
[[ -d $soulseek/magazines/ ]] && rsync $params $soulseek/magazines/ $MEDIA/comics/ >> $SYNC
[[ -d $soulseek/audiobooks/ ]] && rsync $params $soulseek/audiobooks/ $MEDIA/audio/audiobooks/ >> $SYNC

# default
[[ -d $soulseek/ ]] && rsync $params $soulseek/ $MEDIA/audio/music/incoming/unsorted >> $SYNC
[[ -d $soulseek/ ]] && find $soulseek -type d -empty -delete  >> $SYNC


#find $BUFFER -type d -empty -delete
