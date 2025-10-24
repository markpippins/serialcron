#!/bin/bash
# Monitor script for serialcron - view logs in real-time

# Check if LOGS environment variable is set
if [[ -z "$LOGS" ]] || [[ ! -d "$LOGS" ]]; then
    echo "Error: LOGS environment variable not set or directory does not exist." >&2
    exit 1
fi

clear
echo "Monitoring serialcron logs in $LOGS/"
echo "Press Ctrl+C to exit"
echo

# Use tail with specific log files to avoid issues if no .log files exist
if ls "$LOGS"/*.log >/dev/null 2>&1; then
    tail -f "$LOGS"/*.log
else
    echo "No log files found in $LOGS/"
    echo "Waiting for logs to be created..."
    # Wait for new log files to appear and monitor them
    inotifywait -m -e create -e moved_to --format '%w%f' "$LOGS" 2>/dev/null | while read new_file
    do
        if [[ "$new_file" == *.log ]]; then
            echo "New log file detected: $new_file"
            tail -n 0 -f "$new_file"
        fi
    done
fi
