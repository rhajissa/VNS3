#!/usr/bin/env bash

echo "-- Netzwerk erstellen ... ---------------------"
bash bin/create-mynet-network.sh

echo ""
echo "-- Container starten ... ----------------------"
bash bin/start/gatekeeper.sh
bash bin/start/ssh.sh
bash bin/start/managing.sh
bash bin/start/maria.sh
