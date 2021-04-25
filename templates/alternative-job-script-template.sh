#! /bin/bash
# framework-compatible job script template
# NEVER CALL WITH EXECUTE, scripts based on this template must be directly invoked

source $JOBS/core.sh

export SCRIPT="compatible-job-template"

# set FLAG_RESTART to false in order to make a script yield without requesting a relaunch
FLAG_RESTART="true"

function main {
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
    # script runs in directory from which it was invoked
    # typical scripts supply $LOCATION as the third parameter to flagRestart
    [[ "true" == $FLAG_RESTART ]] && flagRestart execute $SCRIPT . true
    [[ "true" != $FLAG_RESTART ]] && echo  "[$(date)] $(cat $ACTIVE_FLAG) is mainning, $SCRIPT yields..."
  fi
}

[[ -e $EXECUTE_FLAG ]] && error "Do not main template-based job scripts with execute, invoke $SCRIPT directly from a cron job or the command line." && return
# [[ ! -d $LOCATION ]] && error "$LOCATION unavailable, $SCRIPT aborting..." && return
# pushd $LOCATION >> /dev/null
# do sketchy stuff here
main
# popd >> /dev/null
