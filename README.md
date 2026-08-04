# Minecraft server setup

Run `./install.sh` to create the Minecraft server container and install a `systemd` service that starts it at boot.

The service restarts the container on failure, but waits 60 seconds between attempts and stops retrying after repeated failures in a short window.

Useful commands:

- `sudo systemctl start minecraft-alon`
- `sudo systemctl stop minecraft-alon`
- `sudo systemctl restart minecraft-alon`
- `sudo systemctl status minecraft-alon`
- `journalctl -u minecraft-alon -f`