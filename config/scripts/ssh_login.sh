#!/usr/bin/expect -f

# Set a timeout for expect blocks (in seconds)
set timeout 30

# Extract command line arguments
set jump_server [lindex $argv 0]
set username [lindex $argv 1]
set password [lindex $argv 2]

# Connect to the jump server via SSH
spawn ssh $username@$jump_server


# Start expect to handle SSH interactions
expect {
    "*yes/no*?" {
        # Automatically answer "yes" to the SSH key verification prompt
        send "yes\r"
        exp_continue
    }
    "*assword:*" {
        # Send the provided password when prompted for it
        send "$password\r"
    }
}

# Allow interaction with the SSH session
interact
