# NixOS Configuration Structure

## Top Level (`/home/grae/nixos/`)

```
.gitignore         - Ignores build result symlink
flake.nix          - Entry point, uses flake-parts + import-tree from ./modules
flake.lock
modules/           - All config is imported via import-tree
result/            - Previous build result symlink (gitignored)
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
  desktop.nix                     - nixosModules.desktop (orchestrates all features)
  settings.nix                    - nixosModules.settings (networking, nix config, locale, zram, tmpfs)
  misc.nix                        - nixosModules.misc (nix-ld, documentation)
  dev-tools.nix                   - nixosModules.dev-tools (languages, LSPs, formatters)
  gaming.nix                      - nixosModules.gaming (steam, gamescope, gamemode)
  power.nix                       - nixosModules.power (power-profiles-daemon, thermald, power-menu)
  lock.nix                        - nixosModules.lock (swaylock, lock-on-suspend)
  hm.nix                          - nixosModules.homeManager + homeManagerModules (nvim, helix, noctalia)
  alacritty.nix                   - nixosModules.alacritty
  fish.nix                        - nixosModules.fish (shell aliases + functions)
  fuzzel.nix                      - nixosModules.fuzzel
  ly.nix                          - nixosModules.ly (display manager)
  mako.nix                        - nixosModules.mako (notification daemon)
  niri.nix                        - nixosModules.niri + perSystem packages.myNiri (with xwayland-satellite)
  noctalia.nix                    - nixosModules.noctalia + perSystem packages.myNoctalia
  nvim/
    default.nix                   - nixosModules.nvim + homeManagerModules.nvim
    config/                       - LazyVim config files (init.lua, lua/, etc.)
  themes/
    default.nix                   - nixosModules.themes (system.theme option)
  wallpaper/default.nix           - nixosModules.wallpaper + perSystem packages (wallpapers, wallpaper-{set,next,init})
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
- **Editor**: neovim (LazyVim-based config)
- **Browser**: librewolf
- **Theme**: Nord color scheme

## Notable Config Features

- **Power**: power-profiles-daemon + thermald for dynamic CPU scaling, power-menu with fuzzel UI
- **Lock**: swaylock with blur+screenshot effects, auto-locks on suspend
- **Bin cache**: nix-community cachix added as substituter
- **Docker**: enabled via virtualisation.docker
- **Gaming**: Steam + gamescope session + gamemode
- **Xwayland**: xwayland-satellite for better X11 app compatibility
- **Dev**: LSPs for most languages, direnv, nix-output-monitor

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
- If lock-on-suspend doesn't trigger, verify `WAYLAND_DISPLAY` matches your session
