#! /bin/bash
# move new music to recently downloaded folders

export SCRIPT="update-recent-music"
params="-rzvp --exclude=.directory --remove-source-files --verbose --progress"

[[ ! -d $MEDIA ]] && error "$MEDIA unavailable, $SCRIPT aborting..." && return

# move /genre/ downloads from ../incoming/unsorted to ../incoming/genre
pushd $MEDIA/audio/music/incoming
for file in *; do
    [[ -d $MEDIA/audio/music/incoming/unsorted/$file ]] && rsync $params $MEDIA/audio/music/incoming/unsorted/$file/* $MEDIA/audio/music/incoming/$file/ >> $SYNC
done
popd
