{ self, inputs, ... }: {
  flake = {
    nixosModules.tmux = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [ tmux ];
    };

    homeManagerModules.tmux = { config, pkgs, lib, systemTheme, ... }: let
      themes = import ../../../themes-data.nix;
      c = themes.${systemTheme}.colors;

      tmuxConfig = pkgs.writeText "tmux.conf" (builtins.replaceStrings
        [
          "@bg@"
          "@fg@"
          "@cyan@"
          "@black@"
          "@gray@"
          "@magenta@"
          "@red@"
          "@green@"
          "@yellow@"
          "@blue@"
          "@orange@"
          "@black4@"
        ]
        [
          c.bg
          c.fg
          c.cyan
          c.black
          c.bg-light
          c.magenta
          c.red
          c.green
          c.yellow
          c.blue
          c.warning
          c.bg-lighter
        ]
        (builtins.readFile ./config/tmux.conf)
      );
    in {
      home.packages = with pkgs; [ tmux ];

      xdg.configFile."tmux/tmux.conf" = {
        source = tmuxConfig;
      };
    };
  };
}
