# serialcron
a BASH utility for scheduling serial execution of cron jobs of indeterminate length

A BASH framework for scheduling serial execution of cron jobs of indeterminate length, with support for queuing and restart flags.

1. place serialcron folder in /opt or another location
2. add $JOBS="/opt/serialcron" to /etc/environment
3. add $LOGS="/opt/serialcron/logs" to /etc/environment
4. sudo ln -s /opt/serialcron/execute.sh /usr/bin/execute
5. sudo ln -s /opt/serialcron/monitor.sh /usr/bin/monitor

# write your script

// #! /bin/bash
// # exported script name appears in logs
// export SCRIPT="sample-script"

// your code goes here

# call execute
#
# first parameter: script name
# the second parameter indicates the directory that the called script is to be performed in
# the third parameter indicates whether the script should be queued if another script is currently executing 

execute sample-script
execute /<path-to>/sample-script
execute sample-script /<execution-location>
execute sample-script /<execution-location> <queue-if-blocked>

# invoke your script from cron

// # cron invocation
// # m h  dom mon dow   command
// 01 * * * * execute sample-script $HOME true  # queue script if a script is running
// 05 * * * * execute sample-script $HOME false # cancel request if a script is running
// 10 * * * * execute sample-script # optionally invoke a script with no directory param **BE CAREFUL**

# use the monitor to see your logs

monitor

