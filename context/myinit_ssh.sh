#!/bin/bash

# Define log file location
log="/log/docker.log"

# Log the start time of the script
echo "$(date +%FT%T) start" >> "$log"

# Signal handler for SIGTERM
trap 'onexit' SIGTERM

# Signal handler for SIGINT
trap 'onint' SIGINT

onint() {
  echo "$(date +%FT%T) signal INT received" >> "$log"
  ps -ef >> "$log"
}

onexit() {
  echo "$(date +%FT%T) shutdown initiated" >> "$log"
  # Retrieve SSHD PID and stop the SSH service
  if [ -f /var/run/sshd.pid ]; then
    read -r sshdpid </var/run/sshd.pid
    service ssh stop
    echo "SSHD PID: $sshdpid stopped" >> "$log"
    # Ensure the SSHD process has stopped
    while ps -p "$sshdpid" > /dev/null; do
      echo "$(date +%FT%T) waiting for SSHD to stop" >> "$log"
      sleep 1
    done
  fi
  ps -ef >> "$log"
  exit
}

# Start SSH service and log
start_ssh() {
  echo "$(date +%FT%T) Starting SSH service" >> "$log"
  service ssh start
  echo "SSH service started" >> "$log"
}

# Main execution
{
  start_ssh
  sleep 1
  # Continuously log a heartbeat message
  while true; do
    echo "$(date +%FT%T) heartbeat" >> "$log"
    sleep 60
  done
} &

