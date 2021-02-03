# serialcron
a BASH framework for scheduling serial execution of cron jobs of indeterminate length

# config

1. place serialcron folder in $USER/bin
2. sudo ln -s $USER/bin/serialcron/execute.sh /usr/bin/execute
3. sudo ln -s $USER/bin/serialcron/monitor.sh /usr/bin/monitor

# cron invocation
# m h  dom mon dow   command
01 * * * * execute <script> <location> true  # queue script if a script is running
05 * * * * execute <script> <location> false # cancel request if a script is running
