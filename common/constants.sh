#! /bin/bash
# constants

export LOGS=$HOME/bin/serialcron/logs

export LOG=$HOME/bin/serialcron/logs/run.log
export DEBUG=$HOME/bin/serialcron/logs/debug.log
export ERRORS=$HOME/bin/serialcron/logs/err.log
export SYNC=$HOME/bin/serialcron/logs/rs.log

export ACTIVE_FLAG=$HOME/bin/serialcron/flags/active.flag
export EXECUTE_FLAG=$HOME/bin/serialcron/flags/execute.flag
export RESTART_FLAG=$HOME/bin/serialcron/flags/restart.flag
export SCRIPT_FLAG=$HOME/bin/serialcron/flags/script.flag
export SLEEP_FLAG=$HOME/bin/serialcron/flags/chill.flag
export TIME_FLAG=$HOME/bin/serialcron/flags/time.flag

# must point to remotely-accessible directory for remote invocation to work
export REMOTE_START_FLAG=$HOME/shared/remote_start.flag

echo "constants loaded"
