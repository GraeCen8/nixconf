{ self, inputs, ... }: {
  flake.nixosModules.mako = { pkgs, lib, config, ... }:
  let
    themes = import ../../themes-data.nix;
    theme = themes.${config.system.theme.name};
    c = theme.colors;

    makoConfig = pkgs.writeText "mako-config" ''
      font=JetBrainsMono Nerd Font 10
      background-color=${c.bg}e6
      text-color=${c.fg}
      border-color=${c.border-active}
      border-size=2
      border-radius=${toString theme.mako.border-radius}
      width=350
      height=150
      margin=12
      padding=12
      default-timeout=5000
      max-visible=5
      anchor=top-right
      layer=overlay
      icons=1
      max-icon-size=32
      markup=1
      sort=-time
    '';
  in {
    environment.systemPackages = with pkgs; [ mako libnotify ];
    environment.etc."mako/config".source = makoConfig;
  };
}
