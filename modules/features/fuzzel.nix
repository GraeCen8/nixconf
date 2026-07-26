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
      background = ${lib.removePrefix "#" c.bg}dd
      text = ${lib.removePrefix "#" c.fg}ff
      prompt = ${lib.removePrefix "#" c.border-active}ff
      input = ${lib.removePrefix "#" c.fg}ff
      match = ${lib.removePrefix "#" c.accent}ff
      selection = ${lib.removePrefix "#" c.bg-alt}ff
      selection-text = ${lib.removePrefix "#" c.fg}ff
      border = ${lib.removePrefix "#" c.border-active}ff
    '';
  in {
    environment.systemPackages = with pkgs; [ fuzzel ];
    environment.etc."xdg/fuzzel/fuzzel.ini".source = fuzzelConfig;
  };
}
