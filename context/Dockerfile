FROM debian:bullseye

# Umgehen von Dialogen und Einstellen der Zeitzone
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Europe/Berlin

# Aktualisierung und Installation aller Pakete in einem Schritt
RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y tzdata vim tree curl w3m netcat less procps dumb-init bat git bc \
    iproute2 net-tools iputils-ping html2text openssh-server sudo apache2 php sysstat mariadb-client \
    bash-completion locales docker.io ca-certificates gnupg jid jc shellcheck \
    pwgen wget net-tools tcpdump bash-builtins bash-completion wrk && \
    ln -s /usr/bin/batcat /usr/local/bin/bat && \
    sed -i "s/^# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Erstellen Sie den Benutzer `myuser` (und die zugehörige Gruppe `myuser`)
RUN useradd -m -s /bin/bash myuser

# Fügen Sie den Benutzer `myuser` zur sudo-Gruppe hinzu
RUN echo 'myuser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

ARG DOCKER_GID=999

# Fügen Sie Ihren Benutzer zur Docker-Gruppe hinzu
RUN usermod -aG docker myuser

# Einstiegspunkt und Standardbefehl
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/bin/myinit.sh"]
