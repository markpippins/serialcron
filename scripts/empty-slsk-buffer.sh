#! /bin/bash
# move FIT256ed audio to SG10/public drive

export SCRIPT="empty-slsk-buffer"
params="-rvz --progress --ignore-existing --exclude=.directory --remove-source-files"

[[ ! -d $FIT256 ]] && error "FIT256 folder unavailable, $SCRIPT aborting..." && return
# [[ ! -d $CACHE ]] && error "Cache folder unavailable, $SCRIPT aborting..." && return
[[ ! -d $SG10/public ]] && error "SG10/public folder unavailable, $SCRIPT aborting..." && return

debug "emptying FIT256..." 
soulseek=$FIT256/public/audio/soulseek/complete
jukebox=$FIT256/public/audio/jukebox

#debug "moving external downloads..." 
#rsync $params $CACHE/incoming/audio/complete/ $soulseek/ >> $LOG

# get rid of uneccesary files
find $soulseek -type f \( -iname \*.m3u -o -iname \*.sfv -o -iname \*.nfo -o -iname \*.cue -o -iname \*.txt \) -delete >> $LOG

# copy new SG10/public files to temp for portable mix
find $soulseek -type f \( -iname \*.flac -o -iname \*.mp3 \) -exec cp -vn {} $jukebox/temp/ \; >> $LOG
find $soulseek -type f \( -iname \*.cbr -o -iname \*.cbz \) -exec cp -vn {} $FIT256/public/comics/ \; >> $LOG

# curated downloads
[[ -d $soulseek/albums/ ]] && rsync $params $soulseek/albums/ $SG10/public/audio/music/albums/ >> $SYNC
[[ -d $soulseek/compilations/ ]] && rsync $params $soulseek/compilations/ $SG10/public/audio/music/compilations/ >> $SYNC
[[ -d $soulseek/random/ ]] && rsync $params $soulseek/random/ $SG10/public/audio/music/random/ >> $SYNC
[[ -d $soulseek/comics/ ]] && rsync $params $soulseek/comics/ $SG10/public/comics/ >> $SYNC
[[ -d $soulseek/books/ ]] && rsync $params $soulseek/books/ $SG10/public/comics/ >> $SYNC
[[ -d $soulseek/magazines/ ]] && rsync $params $soulseek/magazines/ $SG10/public/comics/ >> $SYNC
[[ -d $soulseek/audiobooks/ ]] && rsync $params $soulseek/audiobooks/ $SG10/public/audio/audiobooks/ >> $SYNC

# default
[[ -d $soulseek/* ]] && rsync $params $soulseek/ $SG10/public/audio/music/incoming/unsorted >> $SYNC
[[ -d $soulseek/* ]] && find $soulseek -type d -empty -delete  >> $SYNC


#find $FIT256 -type d -empty -delete
