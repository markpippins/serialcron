#! /bin/bash
# run or queue supplied script, typically invoked by run 

export SCRIPT=$1
export DIRECTORY=$2
export FLAG_RESTART=$3

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
      debug " $SCRIPT complete."
      echo
      restartFlaggedScripts
  else
    [[ "true" == $FLAG_RESTART ]]  && info "$(cat $ACTIVE_FLAG) is running, $SCRIPT flagging restart..." && flagRestart execute $SCRIPT $DIRECTORY $FLAG_RESTART
    [[ -e $ACTIVE_FLAG ]] && [[ "true" != $FLAG_RESTART ]] && info "$(cat $ACTIVE_FLAG) is running, $SCRIPT yields..."
  fi
  [[ -f $EXECUTE_FLAG ]] && rm $EXECUTE_FLAG
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
  [[ ! -d $DIRECTORY ]] && error "$DIRECTORY unavailable, launch of $SCRIPT aborted." && return
  pushd $DIRECTORY >> /dev/null
  run >> $LOG
  popd >> /dev/null
else
  debug "No directory parameter supplied, $SCRIPT executing in $(pwd)"
  run >> $LOG
fi

