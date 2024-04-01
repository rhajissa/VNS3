#!/bin/bash
LC_ALL=C
source local/config.txt  # Ensuring the configuration file is properly loaded with more common syntax

# Set the default number of containers to 1 if no parameter is given
num_containers=${1:-1}

createContainer() {
    local containerIndex="$1"
    local containerName="${containername}-service-${containerIndex}"

    # Check if the container is running
    if docker container inspect "$containerName" &>/dev/null; then
        echo "Container $containerName is already running or exists..."
        return  # Skip to the next container without exiting the script
    fi

    # Create the container with the specified configuration
    docker container create \
        --name "$containerName" \
        --hostname "$containerName" \
        --network mynet \
        --volume "$PWD/www/:/var/www/html" \
        --volume "$PWD/log/:/log" \
        --volume "/var/run/docker.sock:/var/run/docker.sock" \
        --volume "$PWD/context/sysload.sh:/opt/sysload/sysload.sh:ro" \
        --label "traefik.enable=true" \
        --label 'traefik.http.routers.my-web-service.rule=Host(`localhost`)' \
        --label "traefik.http.routers.my-web-service.entrypoints=web" \
        --label "traefik.http.services.my-web-service.loadbalancer.server.port=80" \
        --memory "256m" \
        --cpus "0.5" \
        "$imagename" && echo "Container $containerName has been created." || echo "Failed to create $containerName."

    # Copy the startup file to the container
    if docker container cp context/myinit_services.sh "$containerName:/usr/bin/myinit.sh"; then
        echo "Startup script copied to $containerName."
    else
        echo "Failed to copy startup script to $containerName."
    fi

    # Start the container
    if docker container start "$containerName"; then
        local ip=$(docker container exec "$containerName" hostname -I | cut -d' ' -f1)
        echo "Container $containerName started with IP: $ip"
    else
        echo "Failed to start $containerName."
    fi
}

for ((i=1; i<=num_containers; i++)); do
    createContainer "$i"
done

echo "Finished processing $num_containers container(s)."

