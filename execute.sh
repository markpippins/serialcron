#!/bin/bash
# run or queue supplied script, typically invoked by run 

# Input validation to prevent command injection
if [[ -n "$1" ]]; then
    # Validate script name to prevent path traversal and command injection
    if [[ "$1" =~ [^a-zA-Z0-9_.-] ]]; then
        echo "Error: Invalid script name. Only alphanumeric characters, dots, underscores, and hyphens are allowed."
        exit 1
    fi
    export SCRIPT="$1"
else
    echo "usage: execute <SCRIPT> [DIRECTORY(name)] [FLAG_RESTART(true?)]" >&2
    exit 1
fi

export DIRECTORY="$2"
export FLAG_RESTART="$3"

function run {
  # Use lock file to prevent race conditions when setting the execute flag
  if mkdir "$EXECUTE_FLAG.lock" 2>/dev/null; then
    touch "$EXECUTE_FLAG"
    
    if [[ ! -f $ACTIVE_FLAG ]]; then
        echo
        debug "starting..."
        setActiveFlag "$SCRIPT"

        # find instances of script or script.sh in likely locations and source them
        # Sanitize script name by using basename to prevent path traversal
        local script_basename
        script_basename=$(basename "$SCRIPT")
        
        # Define search paths to avoid potential security issues
        local search_paths=("" "$HOME/" "$HOME/bin/" "$HOME/scripts/" "$JOBS/scripts/")
        
        local found_script=0
        for path in "${search_paths[@]}"; do
            local full_path="${path}${script_basename}"
            
            if [[ -e "$full_path" ]]; then
                source "$full_path" >> "$LOG"
                found_script=1
                break
            fi
            
            full_path="${path}${script_basename}.sh"
            if [[ -e "$full_path" ]]; then
                source "$full_path" >> "$LOG"
                found_script=1
                break
            fi
        done
        
        if [[ $found_script -eq 0 ]]; then
            error "Script '$SCRIPT' not found in any of the expected locations"
        fi

        debug "complete."
        removeActiveFlag
        restartFlaggedScripts
    else
        if [[ "$FLAG_RESTART" == "true" ]]; then
            info "$(cat $ACTIVE_FLAG) is running, $SCRIPT flagging restart..."
            flagRestart execute "$SCRIPT" "$DIRECTORY" "$FLAG_RESTART"
        else
            info "$(cat $ACTIVE_FLAG) is running, $SCRIPT yields..."
        fi
    fi
    
    rm -rf "$EXECUTE_FLAG.lock"  # Remove lock directory
    [[ -f $EXECUTE_FLAG ]] && rm $EXECUTE_FLAG
  else
    # Another instance is already trying to execute, log and exit
    debug "Another execution attempt is in progress, exiting"
    return 1
  fi
}

# setup shell environment
source $JOBS/core.sh

# check for directory param
# if directory unavailable, return without executing script
if (( "$#" != 1 )) 
then   
  if [[ -n "$DIRECTORY" ]]; then
    # Prevent directory traversal attacks by using absolute paths or safe relative paths
    local safe_directory="$DIRECTORY"
    if [[ "$safe_directory" == /* ]]; then
      # It's an absolute path, just check if it exists
      if [[ ! -d "$safe_directory" ]]; then
        error "$safe_directory unavailable, launch of $SCRIPT aborted."
        exit 1
      fi
    else
      # It's a relative path, construct a safe path
      local safe_path
      safe_path="$(cd "$(dirname "$safe_directory")" 2>/dev/null && pwd -P)/$(basename "$safe_directory")"
      if [[ ! -d "$safe_path" ]]; then
        error "$safe_directory unavailable, launch of $SCRIPT aborted."
        exit 1
      fi
      safe_directory="$safe_path"
    fi
    
    cd "$safe_directory" || { error "Cannot change directory to $safe_directory"; exit 1; }
    run >> "$LOG"
    cd - > /dev/null  # Return to previous directory
  else
    # No directory specified but arguments were provided - this is likely an error
    error "No directory provided but arguments were given"
    exit 1
  fi
else
  debug "No directory parameter supplied, $SCRIPT executing in $(pwd)"
  run >> "$LOG"
fi

