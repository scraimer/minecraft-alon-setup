# Minecraft server setup

Run `./install.sh` to create the Minecraft server container and install a `systemd` service that starts it at boot.

The service restarts the container on failure, but waits 60 seconds between attempts and stops retrying after repeated failures in a short window.

## Proximity voice chat

The server runs Fabric with the Simple Voice Chat mod. Each player must install the
Simple Voice Chat client mod for Fabric, matching the Minecraft version used by
the server. The server allows beta versions and may select a beta even when a
compatible release is available.

Voice chat uses UDP port `24454`, which the container publishes on the host. Allow
UDP `24454` through the host firewall; if players connect from outside the local
network, also forward UDP `24454` to this computer in the router. The Minecraft
server itself continues to use TCP port `25566`.

Useful commands:

- `sudo systemctl start minecraft-alon`
- `sudo systemctl stop minecraft-alon`
- `sudo systemctl restart minecraft-alon`
- `sudo systemctl status minecraft-alon`
- `journalctl -u minecraft-alon -f`