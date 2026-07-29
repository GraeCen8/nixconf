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

        extraSpecialArgs = { inherit systemTheme; };

        users.${config.user.name} = { ... }: {
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
          ];

          services.udiskie = {
            enable = true;
            automount = true;
            notify = true;
            tray = "auto";
          };

          imports = [
            self.homeManagerModules.nvim
            self.homeManagerModules.helix
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