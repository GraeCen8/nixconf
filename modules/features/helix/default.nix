{ self, inputs, ... }: {
  flake = {
    nixosModules.helix = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [ helix ];
    };

    homeManagerModules.helix = { config, pkgs, lib, ... }: {
      home.packages = with pkgs; [ helix ];
      home.sessionVariables.EDITOR = lib.mkDefault "hx";

      xdg.configFile."helix" = {
        source = ./config;
        recursive = true;
      };
    };
  };
}
