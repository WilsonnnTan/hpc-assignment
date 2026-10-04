#!/bin/bash
set -e

ssh-keygen -A
mkdir -p /var/run/sshd

# restrict root + password login over SSH
sed -i 's/#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config

SSH_DIR=/home/user/.ssh
SHARED=/shared

mkdir -p "$SSH_DIR" "$SHARED"

# Create the key pair once (first node to start does it, the rest reuse it)
if [ ! -f "$SHARED/id_ed25519" ]; then
    ssh-keygen -t ed25519 -N "" -C "user@cluster" -f "$SHARED/id_ed25519"
fi

cp "$SHARED/id_ed25519"     "$SSH_DIR/id_ed25519"
cp "$SHARED/id_ed25519.pub" "$SSH_DIR/id_ed25519.pub"
cp "$SHARED/id_ed25519.pub" "$SSH_DIR/authorized_keys"

# Don't prompt about unknown hosts when nodes connect to each other
echo "StrictHostKeyChecking no" > "$SSH_DIR/config"

chmod 700 "$SSH_DIR"
chmod 600 "$SSH_DIR/id_ed25519" "$SSH_DIR/authorized_keys" "$SSH_DIR/config"
chown -R user:user "$SSH_DIR"

exec /usr/sbin/sshd -D