{ self, inputs, lib, ... }: {
  options.flake.homeManagerModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
  };

  config.flake = {
    nixosModules.homeManager = { config, pkgs, lib, ... }:
    let
      systemTheme = config.system.theme.name;
    in {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;

        extraSpecialArgs = {
          inherit systemTheme;
          nvimProfile = config.programs.nvim.profile;
        };

        users.${config.user.name} = { pkgs, lib, ... }:
        let
          themes = import ../../themes-data.nix;
          theme = themes.${systemTheme}.gtk;
          accent = lib.toLower theme.accent;
          tweaks = theme.tweaks or [];
          cursor = theme.cursor or theme.accent;
          cursorAccent = lib.toLower cursor;
          cursorName = "catppuccin-${theme.flavor}-${cursorAccent}-cursors";
          gtkThemeName = "catppuccin-${theme.flavor}-${accent}-standard"
            + lib.optionalString (tweaks != []) "+${builtins.concatStringsSep "," tweaks}";
          colors = themes.${systemTheme}.colors;
          accentHex = colors.border-active;
          accentFgHex = colors.bg;
          gnomeAccent = {
            nord = "blue";
            catppuccin-mocha = "purple";
            tokyo-night = "blue";
            minimalist = "slate";
            rose-pine = "purple";
          };
        in {
          home = {
            stateVersion = "26.05";
            username = config.user.name;
            homeDirectory = "/home/${config.user.name}";
          };

          home.packages = with pkgs; [
            gh
            gh-dash
            opencode
            librewolf
            yazi
            clipman
            imv
            mpv
            zathura
            nautilus
          ];

          home.pointerCursor = {
            name = cursorName;
            package = pkgs.catppuccin-cursors.${theme.flavor + cursor};
            gtk.enable = true;
          };

          gtk = {
            enable = true;
            theme = {
              name = gtkThemeName;
              package = pkgs.catppuccin-gtk.override {
                variant = theme.flavor;
                accents = [ accent ];
                inherit tweaks;
              };
            };
            iconTheme = {
              name = "Papirus-Dark";
              package = pkgs.papirus-icon-theme;
            };
            gtk3.extraConfig."gtk-application-prefer-dark-theme" = true;
            gtk4.extraConfig."gtk-application-prefer-dark-theme" = true;
          };

          # libadwaita apps (e.g. nautilus) ignore gtk-theme-name; the
          # color-scheme setting is what makes them follow dark mode.
          dconf.settings."org/gnome/desktop/interface"."color-scheme" =
            "prefer-dark";

          dconf.settings."org/gnome/desktop/interface"."accent-color" =
            gnomeAccent.${systemTheme};

          # libadwaita apps don't take gtk-theme-name, so override the accent
          # hex directly via CSS to match the system theme exactly.
          xdg.configFile."gtk-4.0/gtk.css" = {
            force = true;
            text = ''
              @define-color accent_bg_color ${accentHex};
              @define-color accent_fg_color ${accentFgHex};
              @define-color accent_color ${accentHex};
              @define-color accent_bg_color_hover ${accentHex};
              @define-color accent_bg_color_active ${accentHex};
              @define-color accent_fg_color_hover ${accentFgHex};
              @define-color accent_fg_color_active ${accentFgHex};

              window {
                --accent-bg-color: ${accentHex};
                --accent-bg-color-hover: ${accentHex};
                --accent-bg-color-active: ${accentHex};
                --accent-fg-color: ${accentFgHex};
                --accent-fg-color-hover: ${accentFgHex};
                --accent-fg-color-active: ${accentFgHex};
                --accent-color: ${accentHex};
              }
            '';
          };

          qt.platformTheme.name = "gtk3";

          programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
          };

          programs.git = {
            enable = true;
            userName = "grae ceney";
            userEmail = "gceney7@gmail.com";
            settings = {
              credential.helper = "!/etc/profiles/per-user/grae/bin/gh auth git-credential";
            };
          };

          services.udiskie = {
            enable = true;
            automount = true;
            notify = true;
            tray = "auto";
          };

          xdg.configFile."btop/btop.conf" = {
            force = true;
            text = ''
              theme_background = false
            '';
          };

          imports = [
            self.homeManagerModules.nvim
            self.homeManagerModules.helix
            self.homeManagerModules.tmux
            self.homeManagerModules.noctalia
          ];
        };
      };
    };

    homeManagerModules.noctalia = { config, pkgs, lib, ... }: {
      options.programs.noctalia = {
        enable = lib.mkEnableOption "noctalia shell bar";

        configFile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Path to a JSON config file for noctalia styling";
        };
      };

      config = lib.mkIf config.programs.noctalia.enable {
        xdg.configFile."noctalia/config.json" = lib.mkIf (config.programs.noctalia.configFile != null) {
          source = config.lib.file.mkOutOfStoreSymlink config.programs.noctalia.configFile;
        };
      };
    };
  };
}