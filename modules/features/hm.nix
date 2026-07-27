{ self, inputs, ... }: {
  flake = {
    nixosModules.homeManager = { config, pkgs, lib, ... }: {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;

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
            self.homeManagerModules.noctalia
          ];
        };
      };
    };

    homeManagerModules.nvim = { config, pkgs, lib, ... }: {
    home.packages = with pkgs; [ neovim ];
    home.sessionVariables.EDITOR = "nvim";

    home.activation.createNvimSymlink = lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf ${config.home.homeDirectory}/.config/nvim
      ln -sfn ${./nvim/config} ${config.home.homeDirectory}/.config/nvim
    '';
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