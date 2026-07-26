{ self, inputs, ... }: {
  flake.nixosModules.fuzzel = { pkgs, lib, config, ... }:
  let
    themes = import ../../themes-data.nix;
    theme = themes.${config.system.theme.name};
    c = theme.colors;

    fuzzelConfig = pkgs.writeText "fuzzel.ini" ''
      [main]
      font = JetBrainsMono Nerd Font:size=12
      prompt = "run: "
      terminal = alacritty

      [colors]
      background = ${c.bg}dd
      text = ${c.fg}ff
      prompt = ${c.border-active}ff
      input = ${c.fg}ff
      match = ${c.accent}ff
      selection = ${c.bg-alt}ff
      selection-text = ${c.fg}ff
      border = ${c.border-active}ff
    '';
  in {
    environment.systemPackages = with pkgs; [ fuzzel ];
    environment.etc."xdg/fuzzel/fuzzel.ini".source = fuzzelConfig;
  };
}
