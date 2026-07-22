{ self, inputs, ... }: {
  flake.nixosModules.mako = { pkgs, lib, config, ... }:
  let
    makoConfig = pkgs.writeText "mako-config" ''
      font=JetBrainsMono Nerd Font 10
      background-color=#2e3440e6
      text-color=#d8dee9
      border-color=#81a1c1
      border-size=2
      border-radius=6
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
