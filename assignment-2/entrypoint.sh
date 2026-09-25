#!/bin/bash
set -e

# Generate fresh SSH host keys if they don't exist yet
ssh-keygen -A

mkdir -p /var/run/sshd

# Keep the container alive and serve SSH in the foreground
exec /usr/sbin/sshd -D