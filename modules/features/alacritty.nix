{ self, inputs, ... }:
{
  flake.nixosModules.alacritty = { config, pkgs, lib, ... }:
  let
    alacrittyConfig = pkgs.writeText "alacritty.toml" ''
      [window]
      opacity = 0.9
      decorations = "full"

      [font]
      size = 12.0

      [font.normal]
      family = "JetBrainsMono Nerd Font"

      [scrolling]
      history = 10000

      [colors]
      draw_bold_text_with_bright_colors = true

      [colors.primary]
      background = "#2e3440"
      foreground = "#d8dee9"

      [colors.normal]
      black   = "#3b4252"
      red     = "#bf616a"
      green   = "#a3be8c"
      yellow  = "#ebcb8b"
      blue    = "#81a1c1"
      magenta = "#b48ead"
      cyan    = "#88c0d0"
      white   = "#e5e9f0"

      [colors.bright]
      black   = "#4c566a"
      red     = "#bf616a"
      green   = "#a3be8c"
      yellow  = "#ebcb8b"
      blue    = "#81a1c1"
      magenta = "#b48ead"
      cyan    = "#8fbcbb"
      white   = "#eceff4"

      [cursor]
      style = "Beam"
    '';
  in {
    environment.systemPackages = with pkgs; [
      alacritty
    ];

    environment.etc."alacritty/alacritty.toml".source = alacrittyConfig;

    environment.sessionVariables = {
      TERMINAL = "alacritty";
    };
  };
}
