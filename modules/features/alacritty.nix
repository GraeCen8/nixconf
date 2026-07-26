{ self, inputs, ... }:
{
  flake.nixosModules.alacritty = { config, pkgs, lib, ... }:
  let
    themes = import ../themes/themes.nix;
    theme = themes.${config.system.theme.name};
    c = theme.colors;

    alacrittyConfig = pkgs.writeText "alacritty.toml" ''
      [window]
      opacity = ${toString theme.alacritty.opacity}
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
      background = "${c.bg}"
      foreground = "${c.fg}"

      [colors.normal]
      black   = "${c.black}"
      red     = "${c.red}"
      green   = "${c.green}"
      yellow  = "${c.yellow}"
      blue    = "${c.blue}"
      magenta = "${c.magenta}"
      cyan    = "${c.cyan}"
      white   = "${c.white}"

      [colors.bright]
      black   = "${c.bright-black}"
      red     = "${c.bright-red}"
      green   = "${c.bright-green}"
      yellow  = "${c.bright-yellow}"
      blue    = "${c.bright-blue}"
      magenta = "${c.bright-magenta}"
      cyan    = "${c.bright-cyan}"
      white   = "${c.bright-white}"

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
