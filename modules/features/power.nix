{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.power = {
    pkgs,
    lib,
    config,
    ...
  }: let
    powerMenuScript = pkgs.writeShellScriptBin "power-menu" ''
      current=$(powerprofilesctl get)
      selected=$(powerprofilesctl list | sed -n 's/^[[:space:]]*\**[[:space:]]*//;T;s/:$//p' | while read -r name; do
        if [ "$name" = "$current" ]; then
          printf "%s (active)\n" "$name"
        else
          printf "%s\n" "$name"
        fi
      done | fuzzel --dmenu --prompt="power: ")
      if [ -n "$selected" ]; then
        profile=$(echo "$selected" | sed 's/ (active)//')
        powerprofilesctl set "$profile"
        notify-send "Power Profile" "Switched to $profile"
      fi
    '';
  in {
    services.power-profiles-daemon.enable = true;

    environment.systemPackages = [
      pkgs.power-profiles-daemon
      powerMenuScript
    ];
  };
}
