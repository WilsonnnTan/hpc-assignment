# SSH Cluster Setup

A small Docker cluster where the nodes SSH into each other with a shared key pair.
The key is generated automatically on first start and written to `./shared/`.

## 1. Start the cluster

```bash
docker compose up -d --build
```

Wait a few seconds, then confirm the key was generated:

```bash
ls shared/
# id_ed25519  id_ed25519.pub
```

If the files aren't there yet, check `docker compose logs`.

## 2. Copy the key (required before you can SSH from your host)

SSH refuses private keys that other users can read. The `shared/` folder is a bind mount, so on some systems it has permissions that are too open. Follow the section for your OS.

### Linux

Bind-mounted files keep normal Unix permissions, so you usually just need to tighten them:

```bash
chmod 600 shared/id_ed25519
ssh -p 2222 -i shared/id_ed25519 user@localhost
```

If the file is owned by root (created inside the container), copy it instead:

```bash
mkdir -p ~/.ssh
sudo cp shared/id_ed25519 ~/.ssh/cluster_key
sudo chown "$USER":"$USER" ~/.ssh/cluster_key
chmod 600 ~/.ssh/cluster_key
ssh -p 2222 -i ~/.ssh/cluster_key user@localhost
```

### Windows (WSL)

If the project lives under `/mnt/c/...`, WSL reports every file as `0777` and `chmod` has no effect. Copy the key onto the Linux filesystem:

```bash
mkdir -p ~/.ssh
cp shared/id_ed25519 ~/.ssh/cluster_key
chmod 600 ~/.ssh/cluster_key
ssh -p 2222 -i ~/.ssh/cluster_key user@localhost
```

## 3. Connect

```bash
ssh -p 2222 -i <path-to-copied-key> user@localhost
```

Password login is disabled; only the key works.
