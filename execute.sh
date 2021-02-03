#! /bin/bash
# run or queue supplied script, typically invoked by cron 

export SCRIPT=$1
export DIRECTORY=$2
export FLAG_RESTART=$3


function run {
  [[ ! -f $EXECUTE_FLAG ]] && touch $EXECUTE_FLAG 
  if [[ ! -f $ACTIVE_FLAG ]];
  then
      echo
      debug "starting..."
      setActiveFlag $SCRIPT

      # find insances of script or script.sh in likely locations and source them

      [[ -e $SCRIPT ]] && source $SCRIPT
      [[ -e $SCRIPT.sh ]] && source $SCRIPT.sh
      [[ -e $HOME/$SCRIPT ]] && source $HOME/$SCRIPT
      [[ -e $HOME/$SCRIPT.sh ]] && source $HOME/$SCRIPT.sh
      [[ -e $HOME/bin/$SCRIPT ]] && source $HOME/bin/$SCRIPT
      [[ -e $HOME/bin/$SCRIPT.sh ]] && source $HOME/bin/$SCRIPT.sh
      [[ -e $HOME/bin/serialcron/$SCRIPT ]] && source $HOME/bin/serialcron/$SCRIPT
      [[ -e $HOME/bin/serialcron/$SCRIPT.sh ]] && source $HOME/bin/serialcron/$SCRIPT.sh
      [[ -e $HOME/bin/serialcron/scripts/$SCRIPT ]] && source $HOME/bin/serialcron/scripts/$SCRIPT
      [[ -e $HOME/bin/serialcron/scripts/$SCRIPT.sh ]] && source $HOME/bin/serialcron/scripts/$SCRIPT.sh

      debug "complete."
      removeActiveFlag
      restartFlaggedScripts
  else
    [[ "true" == $FLAG_RESTART ]] && flagRestart execute $SCRIPT $DIRECTORY $FLAG_RESTART
    [[ -e $ACTIVE_FLAG ]] && [[ "true" != $FLAG_RESTART ]] && info "$(cat $ACTIVE_FLAG) is running, $SCRIPT yields..."
  fi
  [[ -f $EXECUTE_FLAG ]] && rm $EXECUTE_FLAG
}

# setup shell environment
source $HOME/bin/serialcron/core.sh

# check usage
[[ -z $SCRIPT ]] && echo "usage: execute <SCRIPT> [DIRECTORY(name)] [FLAG_RESTART(true?)]" && return

# 
if (( "$#" != 1 )) 
then   
  [[ ! -d $DIRECTORY ]] && error "$DIRECTORY unavailable, launch of $SCRIPT aborted." && return
  pushd $DIRECTORY >> /dev/null
  run >> $LOG
  popd >> /dev/null
else
  debug "No directory parameter supplied, $SCRIPT executing in $(pwd)"
  run >> $LOG
fi

