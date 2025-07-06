#!/usr/bin/env sh

# set pid as $PPID if first argument is not specified
p="${1:-$PPID}"

# Use a POSIX compliant way to read output of ps and grep
# Note: The following may not be the most efficient way in sh, but should work for basic cases
output="$(ps ax -o pid= -o ppid= -o comm= | grep -E -i "^\s*$p\s")"

# Read variables from the output using POSIX compliant methods
pid=$(echo "$output" | awk '{print $1}')
ppid=$(echo "$output" | awk '{print $2}')
name=$(echo "$output" | awk '{print $3}')

# Check if $name contains "sshd" and exit if true
if echo "$name" | grep -q "sshd"; then
    exit 0
fi

# Check if $ppid is less than or equal to 1 and exit if true
if [ "$ppid" -le 1 ]; then
    exit 1
fi

# Call the script is_ssh.sh with $ppid as argument
is_ssh.sh "$ppid"
