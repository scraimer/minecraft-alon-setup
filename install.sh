#!/bin/bash
set -e

BASE=/home/shalom/Dropbox/backups/used-for-recovery/linux/services/minecraft/alon
DATA=${BASE}/data
PORT=25566
SERVICE_NAME=minecraft-alon
CONTAINER_NAME=minecraft-alon

echo "==> Creating data directory..."
mkdir -p "${DATA}"

echo "==> Installing systemd service..."
sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null << EOF
[Unit]
Description=Minecraft Server for Alon
After=docker.service network-online.target
Requires=docker.service

[Service]
Type=simple
# Run in foreground (no -d) so systemd tracks the process
ExecStart=/usr/bin/docker run --rm \
    --name ${CONTAINER_NAME} \
    -p ${PORT}:25565 \
    -e EULA=TRUE \
    -e MODE=creative \
    -e RCON_PASSWORD=attackheli \
    -v ${DATA}:/data \
    itzg/minecraft-server
ExecStop=/usr/bin/docker stop ${CONTAINER_NAME}
# Restart on crash, but wait 60s between attempts.
# Stop retrying after 5 failures within 10 minutes.
Restart=on-failure
RestartSec=60
StartLimitIntervalSec=600
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable "${SERVICE_NAME}"
sudo systemctl start "${SERVICE_NAME}"

echo "==> Waiting for Minecraft server to be ready (may take a few minutes)..."
TIMEOUT=300
ELAPSED=0
until docker exec "${CONTAINER_NAME}" rcon-cli help > /dev/null 2>&1; do
    sleep 5
    ELAPSED=$((ELAPSED + 5))
    if [ "${ELAPSED}" -ge "${TIMEOUT}" ]; then
        echo "ERROR: Timed out waiting for server to accept rcon."
        echo "Check logs: journalctl -u ${SERVICE_NAME} -f"
        exit 1
    fi
    echo "  Still waiting... (${ELAPSED}s elapsed)"
done

echo "==> Configuring whitelist and operator..."
# Asaf
docker exec -i "${CONTAINER_NAME}" rcon-cli whitelist add "iron_wall"
docker exec -i "${CONTAINER_NAME}" rcon-cli op "iron_wall"
# Ariel
docker exec -i "${CONTAINER_NAME}" rcon-cli whitelist add "notdiiM"
docker exec -i "${CONTAINER_NAME}" rcon-cli op "notdiiM"


echo ""
echo "==> Done! Minecraft server is running on port ${PORT}."
echo ""
echo "  View logs:    journalctl -u ${SERVICE_NAME} -f"
echo "  Stop server:  sudo systemctl stop ${SERVICE_NAME}"
echo "  Start server: sudo systemctl start ${SERVICE_NAME}"
echo "  Restart:      sudo systemctl restart ${SERVICE_NAME}"
echo "  Status:       sudo systemctl status ${SERVICE_NAME}"

