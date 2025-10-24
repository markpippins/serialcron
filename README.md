# serialcron

A BASH framework for scheduling serial execution of cron jobs of indeterminate length, with support for queuing and restart flags.

## Overview

serialcron is a bash toolkit that ensures only one script runs at a time, preventing conflicts when executing long-running jobs that might overlap. It provides mechanisms to queue job execution, restart jobs when they're blocked, and monitor execution status.

## Features

- **Serial Execution**: Ensures only one job runs at a time
- **Queue System**: Queues jobs when another is running
- **Restart Flagging**: Flags jobs to restart when the active job finishes
- **Comprehensive Logging**: Detailed logging system with debug, info, and error logs
- **Monitoring Tools**: Built-in monitor to watch log output in real-time
- **Flexible Script Location**: Searches for scripts in multiple common locations

## Installation

### 1. Directory Setup
Place the serialcron folder in your user bin directory:
```bash
# Example location
$HOME/bin/serialcron
```

### 2. Environment Configuration
Add the following to `/etc/environment` (or your shell profile):
```bash
JOBS="/home/<username>/bin/serialcron"
LOGS="/path/to/your/log/directory"
```

### 3. Create Symlinks
```bash
sudo ln -s $HOME/bin/serialcron/execute.sh /usr/bin/execute
sudo ln -s $HOME/bin/serialcron/monitor.sh /usr/bin/monitor
```

## Core Components

### Scripts

- **core.sh**: Core functions and utilities for logging, flagging, and execution control
- **execute.sh**: Main execution script that handles queuing and running scripts
- **monitor.sh**: Real-time log monitoring tool
- **templates/**: Pre-built templates for creating new scripts

### Key Functions

- **Logging**: `info()`, `debug()`, `error()` - for different log levels
- **Flag Management**: `setActiveFlag()`, `removeActiveFlag()`, `flagRestart()`
- **Directory Handling**: `mkdirIfAbsent()` - creates directories if they don't exist

## Usage

### 1. Writing Your Script

Create a script that exports a SCRIPT variable for logging:

```bash
#!/bin/bash
# My sample script

export SCRIPT="my-script"

# Your code goes here
echo "Starting my-script..."
# your code here
```

Place your script in one of these locations for execute.sh to find it:
- Current directory
- `$HOME/<script_name>`
- `$HOME/<script_name>.sh`
- `$HOME/bin/<script_name>`
- `$HOME/bin/<script_name>.sh`
- `$HOME/scripts/<script_name>`
- `$HOME/scripts/<script_name>.sh`
- `$JOBS/scripts/<script_name>`
- `$JOBS/scripts/<script_name>.sh`

### 2. Running Scripts

**Basic execution:**
```bash
execute my-script
```

**With directory context:**
```bash
execute my-script /path/to/working/directory
```

**With restart flagging:**
```bash
execute my-script /path/to/working/directory true  # Will restart when the current job finishes
execute my-script /path/to/working/directory false # Will yield without restarting
```

### 3. Cron Integration

Example cron entries:

```bash
# m h  dom mon dow   command
01 * * * * execute my-script $HOME true   # Queue with restart flag if running
05 * * * * execute my-script $HOME false  # Queue without restart flag if running
10 * * * * execute my-script              # Execute with no directory parameter (risky)
```

### 4. Monitoring

Monitor all logs in real-time:
```bash
monitor
```

This is equivalent to:
```bash
tail -f $LOGS/*.log
```

## Script Templates

The toolkit comes with several templates:

### sample-script.sh
Basic template for standard scripts that will be called by execute.sh

### standalone.sh
Template for creating scripts programmatically and executing them

### alternative-job-script-template.sh
Template for scripts that should NOT be called with execute.sh, but run directly

## Logging System

The framework uses multiple log files:

- `$LOGS/debug.log` - Debug information
- `$LOGS/err.log` - Error messages
- `$LOGS/rs.log` - Sync-related logs
- `$LOG` - General log for the running script

## Flags System

The framework uses several flag files to coordinate execution:

- `$FLAGS/active.flag` - Shows currently running script
- `$FLAGS/restart.flag` - Scripts queued for restart
- `$FLAGS/script.flag` - Scripts being processed
- `$FLAGS/execute.flag` - Execution in progress
- `$FLAGS/chill.flag` - Sleep/pause flag
- `$FLAGS/time.flag` - Start time of active script
- `$FLAGS/remote_start.flag` - Remote execution requests

## Functions Reference

### Logging Functions
- `info(message)` - Log information to main log file
- `debug(message)` - Log debug information to debug log
- `error(message)` - Log error and trigger beep

### Flag Functions
- `setActiveFlag(script_name)` - Mark a script as active
- `removeActiveFlag()` - Remove the active flag
- `flagRestart(script, dir, flag, etc)` - Queue a script to restart when possible
- `restartFlaggedScripts()` - Process and run queued restart scripts

### Utility Functions
- `showActiveScripts()` - Display currently active scripts
- `showFlaggedScripts()` - Display queued scripts
- `mkdirIfAbsent(directory)` - Create directory if it doesn't exist

## Best Practices

1. **Always Export SCRIPT**: Your script should export a SCRIPT variable with a meaningful name.

2. **Use Directory Parameters**: When calling execute, consider using a directory parameter to ensure your script runs in the intended location.

3. **Handle Restart Flags Carefully**: Use the restart flag (`true`/`false`) appropriately:
   - `true`: Script will restart after current job finishes
   - `false`: Script will yield without restart

4. **Error Handling**: Use the error() function for logging errors to ensure they're captured in the error log.

5. **Cleanup**: Make sure your scripts clean up appropriately and remove any temporary files.

6. **Testing**: Test scripts manually before adding them to cron jobs.

## Troubleshooting

- If jobs don't seem to be running, check the flag files in `$FLAGS/`
- If logs aren't appearing where expected, verify that `$LOGS` is properly set in `/etc/environment`
- Use the monitor command to watch real-time logs and diagnose issues
- Check that execute.sh has proper permissions and symlinks are working

## Security Considerations

- Be careful when running scripts with no directory parameter (`execute script_name`) as they run in current directory
- Ensure proper permissions on log directories
- Review scripts before adding them to cron jobs
