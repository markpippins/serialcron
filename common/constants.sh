#! /bin/bash
# constants

export SCRIPTS=$JOBS/scripts
export FLAGS=$JOBS/flags

export LOG=$LOGS/serialcron-run.log
export DEBUG=$LOGS/serialcron-debug.log
export ERRORS=$LOGS/serialcron-err.log
export SYNC=$LOGS/serialcron-rs.log

export ACTIVE_FLAG=$FLAGS/active.flag
export EXECUTE_FLAG=$FLAGS/execute.flag
export RESTART_FLAG=$FLAGS/restart.flag
export SCRIPT_FLAG=$FLAGS/script.flag
export SLEEP_FLAG=$FLAGS/chill.flag
export TIME_FLAG=$FLAGS/time.flag
export REMOTE_START_FLAG=$FLAGS/remote_start.flag

export VERBOSE=true
export sleep_time=15
export c="-"
export LINE2="*"
export LINE="$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c$c"

# debug "constants loaded"
