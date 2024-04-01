#!/usr/bin/env bash

source local/config.txt || { echo "Konfigurationsdatei konnte nicht geladen werden."; exit 1; }

containerName="${containername}-gatekeeper"

# Container stoppen und entfernen
stopAndRemoveContainer() {
    if ! docker container inspect "$containerName" &>/dev/null; then
        echo "Container $containerName existiert nicht."
        return
    fi

    if docker stop "$containerName" >/dev/null && docker rm "$containerName" >/dev/null; then
        echo "$containerName wurde erfolgreich gestoppt und entfernt."
    else
        echo "Fehler beim Stoppen oder Entfernen von $containerName."
        exit 1
    fi
}

stopAndRemoveContainer

