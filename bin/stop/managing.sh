#!/bin/bash

# Laden der Konfigurationsdatei, um den Basisnamen zu erhalten
source local/config.txt

# Generieren des Suchmusters basierend auf dem Container-Namensmuster vom Start-Skript
searchPattern="${containername}-service-"

# Sucht nach allen Containern, deren Namen mit dem Muster beginnen
container_ids=$(docker ps -a --format "{{.Names}}" | grep -E "^${searchPattern}[0-9]+\$")

# Stoppt und entfernt jeden gefundenen Container
for container_id in $container_ids; do
    echo "Stopping and removing container: $container_id"
    docker stop "$container_id"
    docker rm "$container_id"
done

echo "All matching containers have been stopped and removed."

