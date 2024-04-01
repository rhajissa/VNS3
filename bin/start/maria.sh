#!/bin/bash
LC_ALL=C
source local/config.txt

containerName="${containername}-data"

checkContainerStatus() {
    # Checks if the container is running
    if docker container ls | grep -q "\b${containerName}$"; then
        echo "Container $containerName is still running..."
        exit 1
    fi

    # Checks if the container exists (even if not running)
    if docker container ls --all | grep -q "\b${containerName}$"; then
        echo "Container $containerName already exists..."
        exit 1
    fi
}

createMariaDBContainer() {
    echo "Creating MariaDB container named $containerName..."

    # Attempts to create the MariaDB container with specified configurations
    docker container create \
        --name "$containerName" \
        --network mynet \
        --volume "$PWD/log/:/log" \
        -e MYSQL_ROOT_PASSWORD="$containerpassword" \
        -e MYSQL_DATABASE=dbdemo \
        -e MYSQL_USER=dbuser \
        -e MYSQL_PASSWORD=lalelu123 \
        mariadb:latest && echo "Container $containerName created successfully." || { echo "Failed to create the container."; exit 1; }

    # Copies initialization scripts to the container
    docker container cp context/init_db.sql "$containerName:/usr/bin/init_db.sql"
    docker container cp context/myinit_data.sh "$containerName:/usr/bin/myinit.sh"

    # Starts the container and executes the initialization script
    docker container start "$containerName"
    docker container exec "$containerName" bash -c "nohup /usr/bin/myinit.sh >/dev/null 2>&1 &"
    echo "MariaDB container $containerName has been started."
}

configureContainerUser() {
    # Configures a user within the container for database interaction
    docker container exec "$containerName" bash -c "useradd -m -s /bin/bash user && echo user:$containerpassword | chpasswd"

    # Creates a MariaDB client configuration for the user
    echo '[client]
user=dbuser
password=lalelu123
host=localhost

[mysql]
database=dbdemo' | docker exec --user user -i "$containerName" tee /home/user/.my.cnf >/dev/null
}

getContainerIP() {
    # Retrieves and displays the IP address of the container
    local ip=$(docker exec "$containerName" hostname -I | cut -d' ' -f1)
    echo "Container IP: $ip"
}

# Script execution flow
checkContainerStatus
createMariaDBContainer
configureContainerUser
getContainerIP

echo "Finished setting up the MariaDB container."

