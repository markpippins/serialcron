#! /bin/bash
# fires when torrent completes
source $JOBS/core.sh

export CALLING_SCRIPT="torrent-complete"

execute empty-torrent-buffer