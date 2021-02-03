#! /bin/bash
# common script functions

source $HOME/bin/serialcron/common/constants.sh

export VERBOSE=true
export sleep_time=15
export c="-"
export LINE2="*"
export LINE="$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c"

export LOAD_TIME=$(date)
export START_TIME=$(date +%Y.%m.%d-%H.%M.%S)

function beep {
    echo -en "\a"
}

function debug {
  # echo "[DEBUG][$(date +%Y.%m.%d-%H.%M.%S)][$SCRIPT] $1"
  echo "[DEBUG][$(date +%Y.%m.%d-%H.%M.%S)][$SCRIPT] $1" >> $DEBUG
  # [[ true == $VERBOSE ]] && echo "[DEBUG][$(date +%Y.%m.%d-%H.%M.%S)][$SCRIPT] $1" >> $LOG
}

export -f debug


function error {
  beep
  echo "[ERROR][$(date +%Y.%m.%d-%H.%M.%S)][$SCRIPT] $1"
  # echo "[ERROR][$(date +%Y.%m.%d-%H.%M.%S)][$SCRIPT] $1" >> $LOG
  # echo "[ERROR][$(date +%Y.%m.%d-%H.%M.%S)][$SCRIPT] $1" >> $DEBUG
  echo "[ERROR][$(date +%Y.%m.%d-%H.%M.%S)][$SCRIPT] $1" >> $ERRORS
}

export -f error


function info {
  echo "[INFO][$(date +%Y.%m.%d-%H.%M.%S)][$SCRIPT] $1" >> $LOG
}

export -f info

# setActiveFlag takes script name as parameter
function setActiveFlag {
  debug "setting active flag."
  echo "$1" > $ACTIVE_FLAG
  echo "$(date)" > $TIME_FLAG
  [[ ! -f $ACTIVE_FLAG ]] && error "active flag was not set for $1"
}

export -f setActiveFlag


function removeActiveFlag {
  if [[ -f  $ACTIVE_FLAG ]];
  then
    debug "removing active flag."
    rm $ACTIVE_FLAG
    rm $TIME_FLAG
    [[ -f $ACTIVE_FLAG ]] && error "active flag remains for $(cat $ACTIVE_FLAG)."
  fi
}

export -f removeActiveFlag


function flagRestart {
  debug "$(cat $ACTIVE_FLAG) is running, flagging restart."
  beep
  echo "$1 $2 $3 $4" >> $RESTART_FLAG
  showActiveScripts >> $DEBUG
  showFlaggedScripts >> $DEBUG
}

export -f flagRestart


function restartFlaggedScripts {
  flag_time=$(date +%Y.%m.%d-%H.%M.%S)
  generated=$SCRIPTS/generated.$flag_time.sh

  if [[ -f $RESTART_FLAG ]] && [[ ! -f $SCRIPT_FLAG ]];
  then
      showFlaggedScripts >> $DEBUG
      touch $SCRIPT_FLAG
      debug "generating $generated..."
      cat $RESTART_FLAG >> $SCRIPT_FLAG
      echo "export SCRIPT=$generated; rm $generated; rm $SCRIPT_FLAG; debug 'complete.'; restartFlaggedScripts" >> $RESTART_FLAG 
      mv $RESTART_FLAG $generated
      debug "launching $generated..."
      source $generated
  fi
}

export -f restartFlaggedScripts

function remoteFlagStart {
  debug "flagging remote start"
  beep
  echo "$1 $2 $3 $4" >> $REMOTE_START_FLAG
  showActiveScripts >> $DEBUG
  showFlaggedScripts >> $DEBUG
}

export -f remoteFlagStart

function startRemotelyFlagged {
  flag_time=$(date +%Y.%m.%d-%H.%M.%S)
  generated=$SCRIPTS/generated.$flag_time.sh

  if [[ -f $REMOTE_START_FLAG ]] && [[ ! -f $SCRIPT_FLAG ]];
  then
      showFlaggedScripts >> $DEBUG
      touch $SCRIPT_FLAG
      debug "generating $generated..."
      cat $REMOTE_START_FLAG >> $SCRIPT_FLAG
      echo "export SCRIPT=$generated; rm $generated; rm $SCRIPT_FLAG; debug 'complete.'; startRemotelyFlagged" >> $REMOTE_START_FLAG 
      mv $REMOTE_START_FLAG $generated
      debug "launching $generated..."
      source $generated
  else
    debug "there are no active scripts." && return
  fi
}

export -f startRemotelyFlagged


function showActiveScripts {
  if [[ ! -e $ACTIVE_FLAG ]];
  then
    echo "there are no active scripts." && return
  else
    echo "$(cat $ACTIVE_FLAG) has been active since $(cat $TIME_FLAG)." && echo $LINE
    [[ -e $SCRIPT_FLAG ]]  && echo "active scripts" && echo $LINE && cat $SCRIPT_FLAG && echo $LINE
  fi
}

export -f showActiveScripts

function showFlaggedScripts {
  if [[ ! -e $RESTART_FLAG ]];
  then
    echo "there are no flagged scripts." && return
  else
    echo "flagged scripts" && echo $LINE
    cat $RESTART_FLAG && echo $LINE
  fi

  if [[ ! -e $REMOTE_START_FLAG ]];
  then
    echo "there are no remote execution requests." && return
  else
    echo "remote execution requests" && echo $LINE
    cat $REMOTE_START_FLAG && echo $LINE
  fi

}

export -f showFlaggedScripts


function mkdirIfAbsent {
    if [[ ! -d $1 ]];
    then
      debug "creating $1"
      mkdir $1
    fi
}

export -f mkdirIfAbsent


function setSleepFlag {
  debug "pausing... "
  touch $SLEEP_FLAG
  sleep $sleep_time
  rm $SLEEP_FLAG
  debug "resuming... "
}

export -f setSleepFlag


function removeFlags {
  find $FLAGS -iname *.flag -delete
  echo "flags removed"
}

export -f removeFlags

mkdirIfAbsent $HOME/bin/serialcron/logs
mkdirIfAbsent $HOME/bin/serialcron/flags
mkdirIfAbsent $HOME/bin/scripts
mkdirIfAbsent $HOME/bin/scripts/generated

echo "core module loaded."
