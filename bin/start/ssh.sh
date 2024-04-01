#!/bin/bash

set -euo pipefail
LC_ALL=C
source local/config.txt

containerName="${containername}-work"

checkContainer() {
    # Exit if container is running or exists
    if docker container ls --all | grep -q "\b${containerName}$"; then
        echo "Container $containerName is still running or exists..."
        exit 1
    fi
}

prepareDirectories() {
    mkdir -p www log
    touch log/docker.log
}

createAndStartContainer() {
    echo "Creating and starting container: $containerName..."

    # Create container
    docker container create \
        --name "$containerName" \
        --hostname "$containerName" \
        --network mynet \
        --volume "$PWD/log/:/log" \
        "$imagename"

    # Copy startup file
    docker container cp context/myinit_work.sh "$containerName:/usr/bin/myinit.sh"

    # Start container and check for errors
    if ! docker container start "$containerName"; then
        echo "Failed to start container $containerName." >&2
        exit 1
    fi
}

configureContainerUser() {
    echo "Configuring user inside the container..."

    # Execute configuration commands within the container
    docker container exec "$containerName" bash -c "
    useradd -m -s /bin/bash user
    echo user:$containerpassword | chpasswd
    sudo -u user ssh-keygen -q -N '' -f /home/user/.ssh/id_rsa
    touch /home/user/.hushlogin
    touch /home/user/.ssh/authorized_keys
    chown user: /home/user/.ssh/authorized_keys
    chmod go-rwx /home/user/.ssh/authorized_keys
    "

    # Copy and set permissions for .vimrc
    docker container cp .vimrc "$containerName:/home/user"
    docker container exec "$containerName" chown user:user /home/user/.vimrc

    # Setup fancy prompt
    printf "%s" "PS1='🐳  \[\e[32m\]\u@\h\[\e[00m\]:\[\e[32m\]\w \[\e[00m\]$ '" |
        docker container exec -i "$containerName" tee -a /home/user/.bashrc >/dev/null

    # Inject public key into authorized_keys
    docker container exec -i "$containerName" tee -a /home/user/.ssh/authorized_keys <~/.ssh/id_rsa.pub >/dev/null
}

setupSSHAccess() {
    echo "Setting up SSH access..."

    # Get IP from container
    local ip=$(docker container inspect "$containerName" | jq -r ".[0].NetworkSettings.Networks.mynet.IPAddress")

    # Remove previous keys for container and add new
    ssh-keygen -q -R "$ip" >/dev/null
    ssh-keyscan "$ip" >>~/.ssh/known_hosts 2>/dev/null

    # Prepare SSH config if not already done
    if ! { test -f ~/.ssh/docker_config && grep -q "^ *Include ~/.ssh/docker_config" ~/.ssh/config; }; then
        echo "Prepare ~/.ssh/config and ~/.ssh/docker_config according to the guide." >&2
        exit 2
    fi

    # Update ~/.ssh/docker_config with the new container host mapping
    sed -i -e "/host ${containerName}$/,/^$/D" ~/.ssh/docker_config
    echo "host ${containerName} # auto
  hostname ${ip}
  user user
" >>~/.ssh/docker_config
}

# Main execution flow
checkContainer
prepareDirectories
createAndStartContainer
configureContainerUser
setupSSHAccess

echo "Container $containerName setup and SSH access configured."

