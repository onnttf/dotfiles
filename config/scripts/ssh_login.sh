#!/usr/bin/expect -f

# Set a timeout for expect blocks (in seconds)
set timeout 30

# Extract command line arguments
set jump_server [lindex $argv 0]
set username [lindex $argv 1]
set password [lindex $argv 2]

# SSH to the jump server
spawn ssh $username@$jump_server

# Start expect
expect {
"*yes/no*?"
{send "yes\r";exp_continue;}
"*assword:*"
{ send "$password\r" }
}

interact
