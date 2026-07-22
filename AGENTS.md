# NixOS Configuration Structure

## Top Level (`/home/grae/nixos/`)

```
flake.nix          - Entry point, uses flake-parts + import-tree from ./modules
flake.lock
modules/           - All config is imported via import-tree
result/            - Previous build result symlink
```

## Modules (`modules/`)

```
parts.nix                         - Defines supported systems (x86_64-linux, aarch64-linux, etc.)
hosts/
  laptop/
    default.nix                   - Defines flake.nixosConfigurations.laptop
    configuration.nix             - Defines nixosModules.laptopConfig (main system config)
    hardware.nix                  - Defines nixosModules.laptopHardware (hardware-specific)
features/
  alacritty/default.nix           - nixosModules.alacritty
  fuzzel/default.nix              - nixosModules.fuzzel
  ly.nix                          - nixosModules.ly (display manager)
  mako/default.nix                - nixosModules.mako (notification daemon)
  niri.nix                        - nixosModules.niri + perSystem packages.myNiri
  noctalia.nix                    - perSystem packages.myNoctalia
  nvim/
    default.nix                   - nixosModules.nvim
    package.nix
    config/                       - Neovim config files (init.lua, lua/, etc.)
  wallpaper/default.nix           - nixosModules.wallpaper + perSystem packages (defaultWallpaper, wallpapers)
  waybar/default.nix              - nixosModules.waybar
```

## Key Details

- **Hostname**: laptop
- **Username**: grae
- **Shell**: fish (with starship prompt)
- **Display Manager**: ly
- **Window Manager**: niri (Wayland compositor)
- **Terminal**: alacritty
- **Launcher**: fuzzel
- **Bar**: waybar
- **Notifications**: mako
- **Wallpaper**: swaybg (with wallpaper-next cycling)
- **Editor**: neovim (NvChad-based config)
- **Browser**: librewolf
- **Theme**: Nord color scheme

## Build Command

```bash
sudo nixos-rebuild switch --flake /home/grae/nixos#laptop
```

Or from within the directory:
```bash
sudo nixos-rebuild switch --flake .#laptop
```

## Common Fixes

- If `opencode` is not in nixpkgs, remove it from `users.users.grae.packages` in `configuration.nix`
- Make sure `stateVersion` matches the nixpkgs channel (currently "26.05")
- The `wrapper-modules` flake input may need updating: `nix flake update`
