{ self, inputs, ... }:
{
  flake.nixosModules.alacritty = { config, pkgs, lib, ... }:
  let
    alacrittyConfig = pkgs.writeText "alacritty.toml" ''
      [window]
      opacity = 0.7
      decorations = "full"

      [font]
      size = 12.0

      [font.normal]
      family = "JetBrainsMono Nerd Font"

      [scrolling]
      history = 10000
    '';
  in {
    environment.systemPackages = with pkgs; [
      alacritty
      nerd-fonts.jetbrains-mono
    ];

    environment.etc."alacritty/alacritty.toml".source = alacrittyConfig;

    environment.sessionVariables = {
      TERMINAL = "alacritty";
    };
  };
}
