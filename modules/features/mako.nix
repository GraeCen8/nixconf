{ self, inputs, ... }: {
  flake.nixosModules.mako = { pkgs, lib, config, ... }:
  let
    themes = import ../../themes-data.nix;
    theme = themes.${config.system.theme.name};
    c = theme.colors;
    radius = toString theme.mako.border-radius;

    makoConfig = pkgs.writeText "mako-config" ''
      font=${themes.font.family} 11

      background-color=${c.bg}
      text-color=${c.fg}
      border-color=${c.border-active}
      border-size=2
      border-radius=${radius}

      width=350
      height=150
      margin=12
      padding=8

      default-timeout=5000
      max-visible=5
      anchor=top-right
      layer=overlay

      icons=1
      max-icon-size=32
      markup=1
      sort=-time
      history=1

      progress-color=over ${c.accent}

      on-button-right=dismiss

      [urgency=low]
      background-color=${c.bg}
      border-color=${c.bg-lighter}

      [urgency=normal]
      background-color=${c.bg}
      border-color=${c.border-active}

      [urgency=critical]
      background-color=${c.bg}
      border-color=${c.error}
      default-timeout=0
    '';
  in {
    environment.systemPackages = with pkgs; [ mako libnotify ];
    environment.etc."xdg/mako/config".source = makoConfig;
  };
}
