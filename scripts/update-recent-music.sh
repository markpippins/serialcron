#! /bin/bash
# move new music to recently downloaded folders

export SCRIPT="update-recent-music"
params="-rzvp --exclude=.directory --remove-source-files --verbose --progress"

[[ ! -d $SG10 ]] && error "$SG10 unavailable, $SCRIPT aborting..." && return

# move /genre/ downloads from ../incoming/unsorted to ../incoming/genre
pushd $SG10/audio/music/incoming
for file in *; do
    [[ -d $SG10/audio/music/incoming/unsorted/$file ]] && rsync $params $SG10/audio/music/incoming/unsorted/$file/* $SG10/audio/music/incoming/$file/ >> $SYNC
done
popd
