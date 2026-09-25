# Assignment 2 - Docker Compose Cluster (1 Head Node + 2 Compute Nodes)

## What's inside
- **Dockerfile** - custom image (`cluster-node`) based on `ubuntu:22.04` with
  `openssh-server`, `openssh-client`, and editors (`nano`, `vim`) installed on
  every node, as required.
- **entrypoint.sh** - generates SSH host keys and starts `sshd` in the foreground.
- **docker-compose.yml** - spins up 3 containers on a private bridge network:
  - `headnode` (172.28.0.10) - SSH exposed to host on port `2222`
  - `computenode1` (172.28.0.11) - can only be accessed via headnode
  - `computenode2` (172.28.0.12) - can only be accessed via headnode
- A shared Docker volume (`/shared`) is mounted on all nodes for shared storage.

## Build & start the cluster
```bash
docker compose up -d --build
```

## Check the nodes
```bash
docker compose ps
docker ps
```

## Log into the head node
```bash
ssh root@localhost -p 2222        # password: cluster123
```

## Test passwordless SSH between nodes (run from inside headnode)
```bash
ssh root@172.28.0.11              # password: cluster123
ssh root@172.28.0.11              # password: cluster123
```

## Stop / tear down
```bash
docker compose down -v
```