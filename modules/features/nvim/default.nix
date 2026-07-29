{ self, inputs, ... }: {
  flake = {
    nixosModules.nvim = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [ neovim ];
    };

    homeManagerModules.nvim = { config, pkgs, lib, ... }: {
      home.packages = with pkgs; [ neovim ];
      home.sessionVariables.EDITOR = "nvim";

      xdg.configFile."nvim" = {
        source = ./config;
        recursive = true;
      };
    };
  };
}
