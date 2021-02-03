#! /bin/bash
# constants

# export LOGS=$HOME/bin/jobs/logs
# export FLAGS=$HOME/bin/jobs/flags
# export SCRIPTS=$HOME/bin/jobs/scripts

export LOG=$HOME/bin/jobs/logs/run.log
export DEBUG=$HOME/bin/jobs/logs/debug.log
export ERRORS=$HOME/bin/jobs/logs/err.log
export SYNC=$HOME/bin/jobs/logs/rs.log

export ACTIVE_FLAG=$HOME/bin/jobs/flags/active.flag
export EXECUTE_FLAG=$HOME/bin/jobs/flags/execute.flag
export RESTART_FLAG=$HOME/bin/jobs/flags/restart.flag
export SCRIPT_FLAG=$HOME/bin/jobs/flags/script.flag
export SLEEP_FLAG=$HOME/bin/jobs/flags/chill.flag
export TIME_FLAG=$HOME/bin/jobs/flags/time.flag
export REMOTE_START_FLAG=/media/vitriol-armor/remote_start.flag

echo "constants loaded"
