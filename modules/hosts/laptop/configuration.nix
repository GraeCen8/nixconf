{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.laptopConfig = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.laptopHardware
      self.nixosModules.desktop
      self.nixosModules.settings
    ];

    users.groups.${config.user.name} = {};
    users.users.${config.user.name} = {
      isNormalUser = true;
      group = "grae";
      description = "grae ceney";
      extraGroups = ["wheel" "networkmanager"];
    };
    services.upower.enable = true;
    programs.niri.bar = "waybar"; # "waybar" "noctalia" "quickshell"

    system.theme.name = "catppuccin-mocha";
    system.stateVersion = "26.05"; # don't change
  };
}
