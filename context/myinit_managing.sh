#!/bin/bash

log="/log/docker.log"

echo "$(date +%FT%T) start" >> "$log"

trap 'onint' SIGINT
trap 'onexit' SIGTERM

onint() {
  echo "$(date +%FT%T) signal INT received" >> "$log"
  ps -ef >> "$log"
}

onexit() {
  echo "$(date +%FT%T) shutdown initiated" >> "$log"
  # Retrieve Apache PID
  if [ -f /run/apache2/apache2.pid ]; then
    read -r apachepid </run/apache2/apache2.pid
    apachectl stop
    echo "$apachepid" >> "$log"
    # Wait for Apache to stop
    while ps -p "$apachepid" > /dev/null; do
      echo "$(date +%FT%T) waiting for Apache to stop" >> "$log"
      sleep 1
    done
  fi
  ps -ef >> "$log"
  exit
}

# Start services and configure Apache to serve the server-status page
configure_apache() {
  echo "Configuring Apache server-status module" >> "$log"
  {
    echo "LoadModule status_module modules/mod_status.so"
    echo "<Location \"/server-status\">"
    echo "    SetHandler server-status"
    echo "    Require local"
    echo "</Location>"
    echo "ExtendedStatus On"
  } >> /etc/apache2/apache2.conf
  apachectl start
}

# Log system load periodically
monitor_sysload() {
  while true; do
    echo "$(date +%FT%T) system check" >> "$log"
    /opt/sysload/sysload.sh >> "$log"
    sleep 60
  done
}


{
  configure_apache
  sleep 1
  monitor_sysload
} &

