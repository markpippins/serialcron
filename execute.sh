#!/bin/bash
# run or queue supplied script, typically invoked by run 

# Input validation to prevent command injection
if [[ -n "$1" ]]; then
    # Validate script name to prevent path traversal and command injection
    if [[ "$1" =~ [^a-zA-Z0-9_.-] ]]; then
        echo "Error: Invalid script name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
        exit 1
    fi
    export SCRIPT="$1"
else
    echo "usage: execute <SCRIPT> [DIRECTORY(name)] [FLAG_RESTART(true?)]" >&2
    exit 1
fi

export DIRECTORY="$2"
export FLAG_RESTART="$3"

function run {
  [[ ! -f $EXECUTE_FLAG ]] && touch $EXECUTE_FLAG 
  if [[ ! -f $ACTIVE_FLAG ]];
  then
      echo
      debug " $SCRIPT starting..."
      setActiveFlag $SCRIPT

      # find instances of script or script.sh in likely locations and source them

      [[ -e $SCRIPT ]] && source $SCRIPT >> $LOG
      [[ -e $SCRIPT.sh ]] && source $SCRIPT.sh >> $LOG
      [[ -e $HOME/$SCRIPT ]] && source $HOME/$SCRIPT >> $LOG
      [[ -e $HOME/$SCRIPT.sh ]] && source $HOME/$SCRIPT.sh >> $LOG
      [[ -e $HOME/bin/$SCRIPT ]] && source $HOME/bin/$SCRIPT >> $LOG
      [[ -e $HOME/bin/$SCRIPT.sh ]] && source $HOME/bin/$SCRIPT.sh >> $LOG
      [[ -e $HOME/scripts/$SCRIPT ]] && source $HOME/scripts/$SCRIPT >> $LOG
      [[ -e $HOME/scripts/$SCRIPT.sh ]] && source $HOME/scripts/$SCRIPT.sh >> $LOG
      [[ -e $JOBS/scripts/$SCRIPT ]] && source $JOBS/scripts/$SCRIPT >> $LOG
      [[ -e $JOBS/scripts/$SCRIPT.sh ]] && source $JOBS/scripts/$SCRIPT.sh >> $LOG

      removeActiveFlag
      debug "$SCRIPT complete."
      echo
      restartFlaggedScripts
  else
    # Another instance is already trying to execute, log and exit
    debug "Another execution attempt is in progress, exiting"
    return 1
  fi
}

# setup shell environment

source /etc/environment
source $JOBS/core.sh
# check usage
[[ -z $SCRIPT ]] && echo "usage: execute <SCRIPT> [DIRECTORY(name)] [FLAG_RESTART(true?)]" && return

# check for directory param
# if directory unavailable, return without executing script
if (( "$#" != 1 )) 
then   
  debug "..."
  [[ ! -d $DIRECTORY ]] && error "$DIRECTORY unavailable, launch of $SCRIPT aborted." && return
  pushd $DIRECTORY >> /dev/null
  run >> $LOG
  popd >> /dev/null
else
  debug "..."
  debug "No directory parameter supplied, launching $SCRIPT in $(pwd)"
  run >> $LOG
fi

