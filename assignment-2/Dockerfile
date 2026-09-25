FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ---- Software required on every node: editor, openssh-server, openssh-client ----
RUN apt-get update && apt-get install -y --no-install-recommends \
        openssh-server \
        openssh-client \
        nano \
        vim \
        sudo \
        iputils-ping \
        net-tools \
        iproute2 \
    && mkdir -p /var/run/sshd \
    && rm -rf /var/lib/apt/lists/*

# Simple root password (lab/testing use only)
RUN echo 'root:cluster123' | chpasswd

# Allow root login + password auth over SSH
RUN sed -i 's/#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config \
    && echo "    UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]