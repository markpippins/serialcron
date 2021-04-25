#! /bin/bash
# use this pattern to perform an operation asynchronously and then invoke a job request

mkdir bin/scripts

echo "#! /bin/bash" >> bin/scripts/hello.sh
echo "this is a serial-cron script" >> bin/scripts/hello.sh
echo >> bin/scripts/hello.sh
echo "ls -al > dir-listing.txt" >> bin/scripts/hello.sh

# reminder: the script performs in the supplied location only if that location is found

execute hello $USER
