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
      text = d8dee9ff
      prompt = 81a1c1ff
      input = d8dee9ff
      match = 88c0d0ff
      selection = 3b4252ff
      selection-text = d8dee9ff
      border = 81a1c1ff
    '';
  in {
    environment.systemPackages = with pkgs; [ fuzzel ];
    environment.etc."xdg/fuzzel/fuzzel.ini".source = fuzzelConfig;
  };
}
