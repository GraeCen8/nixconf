{ self, inputs, ... }: {
  flake.nixosModules.fuzzel = { pkgs, lib, config, ... }:
  let
    fuzzelConfig = pkgs.writeText "fuzzel.ini" ''
      [main]
      font = JetBrainsMono Nerd Font:size=12
      prompt = "run: "
      terminal = alacritty

      [colors]
      background = 2e3440dd
      text = d8dee9
      prompt = 81a1c1
      input = d8dee9
      match = 88c0d0
      selection = 3b4252
      selection-text = d8dee9
      border = 81a1c1
    '';
  in {
    environment.systemPackages = with pkgs; [ fuzzel ];
    environment.etc."fuzzel/fuzzel.ini".source = fuzzelConfig;
  };
}
