#!/usr/bin/env bash

echo "-- Container stoppen ... ----------------------"
bash bin/start/gatekeeper.sh
bash bin/start/ssh.sh
bash bin/start/managing.sh
bash bin/start/maria.sh

echo ""
echo "-- Netzwerk entfernen ... ---------------------"
bash bin/remove-mynet-network.sh
