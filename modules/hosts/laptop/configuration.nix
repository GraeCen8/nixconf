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
      self.nixosModules.gaming
    ];

    networking.hostName = "nixos-example";
    user.name = "grae";
    user.fullName = "grae ceney";

    boot.tmp.useTmpfs = true;

    programs.niri.bar = "waybar";
    system.theme.name = "tokyo-night";

    system.stateVersion = "26.05";
  };
}
