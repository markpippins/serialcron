# serialcron
a BASH framework for scheduling serial execution of cron jobs of indeterminate length

# config

1. place serialcron folder in $USER/bin
2. add $JOBS="/home/<username>/bin/serialcron" to /etc/environment
3. add $LOGS="/your/log/directory" to /etc/environment
4. sudo ln -s $USER/bin/serialcron/execute.sh /usr/bin/execute
5. sudo ln -s $USER/bin/serialcron/monitor.sh /usr/bin/monitor

# usage

_1. write your script:_

#! /bin/bash
# describe your script here

export SCRIPT="sample-script"
# the exported SCRIPT will appear in the logs. it should generally match the file name.

# your code goes here

_2. call your code from the command line:_

execute sample-script ~/target-directory true

_3. invoke your script from cron_

# cron invocation
# m h  dom mon dow   command
01 * * * * execute sample-script $USER true  # queue script if a script is running
05 * * * * execute sample-script $USER false # cancel request if a script is running
10 * * * * execute sample-script # optionally invoke a script with no directory param **BE CAREFUL**

_4. use the monitor to see your logs
