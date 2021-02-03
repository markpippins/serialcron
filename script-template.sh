#! /bin/bash
# framework-compatible job script template
# NEVER CALL WITH EXECUTE
source $BIN/serialcron/core.sh

export SCRIPT="script-template"
FLAG_RESTART="true"

function run {
  if [[ ! -f $ACTIVE_FLAG ]] && [[ ! -f $SCRIPT_FLAG ]] && [[ ! -e $EXECUTE_FLAG ]] ;
  then
      echo >> $LOG
      debug "starting..."
      setActiveFlag $SCRIPT

      # your code goes here
      
      removeActiveFlag
      debug "complete"
      restartFlaggedScripts
  else
    # template script runs in directory from which it was invoked
    # typical scripts supply $LOCATION as the third parameter to flagRestart
    [[ "true" == $FLAG_RESTART ]] && flagRestart execute $SCRIPT . $FLAG_RESTART 
    [[ "true" != $FLAG_RESTART ]] && echo  "[$(date)] $(cat $ACTIVE_FLAG) is running, $SCRIPT yields..."
  fi
}

[[ -e $EXECUTE_FLAG ]] && error "Do not start template-based job scripts with execute, invoke $SCRIPT directly from a cron job or the command line." && return
# [[ ! -d $LOCATION ]] && error "$LOCATION unavailable, $SCRIPT aborting..." && return
# pushd $LOCATION >> /dev/null
# do sketchy stuff here
run
# popd >> /dev/null
