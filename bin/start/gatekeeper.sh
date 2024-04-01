#!/usr/bin/env bash

set -euo pipefail
LC_ALL=C

# Sicherstellen, dass die Konfigurationsdatei existiert und einbinden
configFile="local/config.txt"
if [ ! -f "$configFile" ]; then
    echo "Konfigurationsdatei '$configFile' nicht gefunden."
    exit 1
fi
source "$configFile"

containerName="${containername}-gatekeeper"

# Funktion, um zu überprüfen, ob der Container läuft oder existiert
checkContainer() {
    if docker container inspect "$containerName" &>/dev/null; then
        echo "Container $containerName läuft bereits oder existiert."
        exit 1
    fi
}

# Funktion, um den Traefik-Container zu erstellen
createTraefikContainer() {
    echo "Erstelle Traefik-Container: $containerName..."

    if docker container create \
        --name "$containerName" \
        --hostname "traefik" \
        --network "mynet" \
        --volume "/var/run/docker.sock:/var/run/docker.sock" \
        --volume "$PWD/traefik.yml:/traefik.yml" \
        --publish 80:80 \
        --publish 8080:8080 \
        traefik:v2.4 \
        --log.level=DEBUG \
        --api.insecure=true \
        --providers.docker=true \
        --providers.docker.exposedbydefault=false \
        --entrypoints.web.address=:80; then
        echo "Traefik-Container $containerName wurde erfolgreich erstellt."
    else
        echo "Fehler beim Erstellen des Traefik-Containers $containerName."
        exit 1
    fi
}

# Funktion, um den Container zu starten
startContainer() {
    echo "Starte Container: $containerName..."
    if docker container start "$containerName"; then
        echo "$containerName wurde erfolgreich gestartet."
    else
        echo "Fehler beim Starten von $containerName." >&2
        exit 1
    fi
}

# Funktion, um die IP-Adresse des Containers zu ermitteln
retrieveIPAddress() {
    local ip
    ip=$(docker container inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$containerName")
    echo "Traefik läuft unter: $ip"
}

# Hauptausführungsfluss
checkContainer
createTraefikContainer
startContainer
retrieveIPAddress

echo "Traefik-Setup abgeschlossen."

