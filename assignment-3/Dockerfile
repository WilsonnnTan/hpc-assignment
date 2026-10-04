FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ---- Software required on every node: editor, openssh-server, openssh-client ----
RUN apt-get update && apt-get install -y --no-install-recommends \
        openssh-server \
        openssh-client \
        nano \
        sudo \
        iputils-ping \
        net-tools \
        iproute2 \
    && mkdir -p /var/run/sshd \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash user \
    && echo "user:user" | chpasswd

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]