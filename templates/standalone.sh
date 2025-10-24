#!/bin/bash
# use this pattern to perform an operation asynchronously and then invoke a job request

# Create the scripts directory if it doesn't exist
mkdir -p "$HOME/bin/scripts"

# Create a sample script file
cat > "$HOME/bin/scripts/hello.sh" << 'EOF'
#!/bin/bash
# Sample dynamically created script for serialcron
export SCRIPT="hello"

echo "Hello from dynamically created script!"
date > dir-listing-$(date +%Y%m%d-%H%M%S).txt
ls -al >> dir-listing-$(date +%Y%m%d-%H%M%S).txt
echo "Script completed at $(date)"
EOF

# Make the script executable
chmod +x "$HOME/bin/scripts/hello.sh"

# reminder: the script performs in the supplied location only if that location is found
execute hello "$HOME" true
