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
    system.theme.uiScale = 1.0; # 1920px primary monitor / 1920 reference
    programs.nvim.profile = "minimal"; # "full" (LazyVim) or "minimal" (lazy.nvim)

    system.stateVersion = "26.05";
  };
}
