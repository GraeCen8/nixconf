# New Machine Bootstrap

```bash
# 1. Enable flakes on fresh install
sudo mkdir -p /etc/nix
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
sudo systemctl restart nix-daemon

# 2. Clone your config
nix-shell -p git --run "git clone <your-repo-url> /home/grae/nixos"

# 3. Get new machine's hardware config
nixos-generate-config --show-hardware-config

# 4. Copy UUIDs and kernel modules into modules/hosts/<host>/hardware.nix

# 5. Rebuild
sudo nixos-rebuild switch --flake /home/grae/nixos#<host>
```
