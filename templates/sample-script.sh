#!/bin/bash
# Sample script for serialcron framework
# This script will be called by execute.sh

# The exported SCRIPT will appear in the logs. It should generally match the file name.
# Use only alphanumeric characters, dots, underscores, and hyphens in the script name.
export SCRIPT="sample-script"

# Your code starts here
echo "Sample script is running..."

# Example of using the logging functions available through core.sh:
# debug "This is a debug message"
# info "This is an info message" 
# error "This is an error message"

# Your actual script logic goes here
# For example:
#   - Perform some operations
#   - Process data
#   - Run commands
#   - etc.

echo "Sample script completed."
