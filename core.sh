#!/bin/bash
# common script functions

export LOAD_TIME=$(date)
export START_TIME=$(date +%Y.%m.%d-%H.%M.%S)

source /etc/environment
source $JOBS/common/constants.sh
# source $JOBS/common/data.sh

function beep {
    echo -en "\a"
}

function debug {
  # Add lock file to prevent race conditions in logging
  local log_lock="$DEBUG.lock"
  (
    flock -x 200
    echo "[DEBUG][$(date +%Y.%m.%d-%H.%M.%S)][$SCRIPT] $1" >> "$DEBUG"
  ) 200>"$log_lock"
  # [[ true == $VERBOSE ]] && echo "[DEBUG][$(date +%Y.%m.%d-%H.%M.%S)][$SCRIPT] $1" >> $LOG
}

export -f debug


function error {
  beep
  local message="[ERROR][$(date +%Y.%m.%d-%H.%M.%S)][$SCRIPT] $1"
  echo "$message"
  # Add lock file to prevent race conditions in logging
  local log_lock="$ERRORS.lock"
  (
    flock -x 200
    echo "$message" >> "$ERRORS"
  ) 200>"$log_lock"
  # echo "[ERROR][$(date +%Y.%m.%d-%H.%M.%S)][$SCRIPT] $1" >> $LOG
  # echo "[ERROR][$(date +%Y.%m.%d-%H.%M.%S)][$SCRIPT] $1" >> $DEBUG
}

export -f error


function info {
  local message="[INFO][$(date +%Y.%m.%d-%H.%M.%S)][$SCRIPT] $1"
  # Add lock file to prevent race conditions in logging
  local log_lock="$LOG.lock"
  (
    flock -x 200
    echo "$message" >> "$LOG"
  ) 200>"$log_lock"
}

export -f info

# setActiveFlag takes script name as parameter
function setActiveFlag {
  debug "setting active flag."
  # Use flock to prevent race conditions
  (
    flock -x 200
    echo "$1" > "$ACTIVE_FLAG"
    echo "$(date)" > "$TIME_FLAG"
  ) 200>"$ACTIVE_FLAG.lock"
  
  if [[ ! -f $ACTIVE_FLAG ]]; then
    error "active flag was not set for $1"
  fi
}

export -f setActiveFlag


function removeActiveFlag {
  debug "removing active flag."
  if [[ -f $ACTIVE_FLAG ]]; then
    # Use flock to prevent race conditions when removing the flag
    (
      flock -x 200
      # Double check existence inside lock to prevent race condition
      if [[ -f $ACTIVE_FLAG ]]; then
        rm -f "$ACTIVE_FLAG"
        rm -f "$TIME_FLAG"
      fi
    ) 200>"$ACTIVE_FLAG.lock"
    
    # Check if flag still exists after removal attempt
    if [[ -f $ACTIVE_FLAG ]]; then
      error "active flag remains for $(cat $ACTIVE_FLAG 2>/dev/null || echo "unknown")."
    fi
  else 
    debug "no active flag found."
  fi
}

export -f removeActiveFlag


function flagRestart {
  debug "$(cat $ACTIVE_FLAG 2>/dev/null || echo 'unknown') is running, flagging restart."
  beep
  # Use flock to prevent race conditions when writing to the restart flag
  (
    flock -x 200
    echo "$1 $2 $3 $4" >> "$RESTART_FLAG"
  ) 200>"$RESTART_FLAG.lock"
  showActiveScripts >> "$DEBUG"
  showFlaggedScripts >> "$DEBUG"
}

export -f flagRestart


function restartFlaggedScripts {
  flag_time=$(date +%Y.%m.%d-%H.%M.%S)
  generated=$SCRIPTS/generated/dynamic.$flag_time.sh

  # Use flock to prevent race conditions when processing restart flags
  (
    flock -x 200
    if [[ -f $RESTART_FLAG ]] && [[ ! -f $SCRIPT_FLAG ]]; then
        debug "restarting flagged scripts..."
        showFlaggedScripts >> "$DEBUG"
        touch "$SCRIPT_FLAG"
        debug "generating $generated..."
        cat "$RESTART_FLAG" >> "$SCRIPT_FLAG"
        echo "export SCRIPT=$generated; rm $generated; rm $SCRIPT_FLAG; debug 'complete.'; restartFlaggedScripts" >> "$RESTART_FLAG" 
        mv "$RESTART_FLAG" "$generated"
        debug "launching $generated..."
        source "$generated"
    fi
  ) 200>"$RESTART_FLAG.lock"
}

export -f restartFlaggedScripts

function remoteFlagStart {
  debug "flagging remote start"
  beep
  # Use flock to prevent race conditions when writing to the remote start flag
  (
    flock -x 200
    echo "$1 $2 $3 $4" >> "$REMOTE_START_FLAG"
  ) 200>"$REMOTE_START_FLAG.lock"
  showActiveScripts >> "$DEBUG"
  showFlaggedScripts >> "$DEBUG"
}

export -f remoteFlagStart

function startRemotelyFlagged {
  flag_time=$(date +%Y.%m.%d-%H.%M.%S)
  generated=$SCRIPTS/generated.$flag_time.sh

  # Use flock to prevent race conditions when processing remote start flags
  (
    flock -x 200
    if [[ -f $REMOTE_START_FLAG ]] && [[ ! -f $SCRIPT_FLAG ]]; then
        showFlaggedScripts >> "$DEBUG"
        touch "$SCRIPT_FLAG"
        debug "generating $generated..."
        cat "$REMOTE_START_FLAG" >> "$SCRIPT_FLAG"
        echo "export SCRIPT=$generated; rm $generated; rm $SCRIPT_FLAG; debug 'complete.'; startRemotelyFlagged" >> "$REMOTE_START_FLAG" 
        mv "$REMOTE_START_FLAG" "$generated"
        debug "launching $generated..."
        source "$generated"
    else
      debug "there are no active scripts." && return
    fi
  ) 200>"$REMOTE_START_FLAG.lock"
}

export -f startRemotelyFlagged


function showActiveScripts {
  if [[ ! -e $ACTIVE_FLAG ]]; then
    echo "there are no active scripts." && return
  else
    local active_script
    active_script=$(cat "$ACTIVE_FLAG" 2>/dev/null || echo "unknown")
    local start_time
    start_time=$(cat "$TIME_FLAG" 2>/dev/null || echo "unknown")
    echo "$active_script has been active since $start_time." && echo $LINE
    [[ -e $SCRIPT_FLAG ]]  && echo "active scripts" && echo $LINE && cat "$SCRIPT_FLAG" && echo $LINE
  fi
}

export -f showActiveScripts

function showFlaggedScripts {
  if [[ ! -e $RESTART_FLAG ]]; then
    echo "there are no flagged scripts." && return
  else
    echo "flagged scripts" && echo $LINE
    cat "$RESTART_FLAG" && echo $LINE
  fi

  if [[ ! -e $REMOTE_START_FLAG ]]; then
    echo "there are no remote execution requests." && return
  else
    echo "remote execution requests" && echo $LINE
    cat "$REMOTE_START_FLAG" && echo $LINE
  fi

}

export -f showFlaggedScripts


function mkdirIfAbsent {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
      debug "creating $dir"
      mkdir -p "$dir"
    fi
}

export -f mkdirIfAbsent


function setSleepFlag {
  debug "pausing... "
  touch "$SLEEP_FLAG"
  sleep "$sleep_time"
  rm -f "$SLEEP_FLAG"
  debug "resuming... "
}

export -f setSleepFlag


function removeFlags {
  find "$FLAGS" -iname "*.flag" -delete
  echo "flags removed"
}

export -f removeFlags


mkdirIfAbsent "$JOBS/logs"
mkdirIfAbsent "$FLAGS"
mkdirIfAbsent "$JOBS/scripts"
mkdirIfAbsent "$JOBS/scripts/generated"

# debug "core module loaded."
