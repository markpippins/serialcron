#! /bin/bash
# move logs to backup folder, delete old log backups

export SCRIPT="cycle-logs.sh"
KEEP_LOG_DAYS=45

mkdirIfAbsent $LOGS/bak

debug "backing up logs..."
mkdir $LOGS/bak/$START_TIME  >> $LOG

cp $LOG $LOGS/bak/$START_TIME/  >> $LOG
truncate -s 0 $LOG

cp $SYNC $LOGS/bak/$START_TIME/  >> $LOG
truncate -s 0 $SYNC

cp $ERRORS $LOGS/bak/$START_TIME/  >> $LOG
truncate -s 0 $ERRORS

cp $DEBUG $LOGS/bak/$START_TIME/  >> $LOG
truncate -s 0 $DEBUG

debug "deleting old backups..."
find $LOGS/bak/*.* -ctime +$KEEP_LOG_DAYS -delete  >> $LOG
find $LOGS/bak -type d -empty -delete  >> $LOG