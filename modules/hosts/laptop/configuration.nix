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

    networking.hostName = "nixos-laptop";

    boot.loader.systemd-boot = {
      enable = true;
      consoleMode = "max";
      configurationLimit = 10;
    };
    boot.loader.efi.canTouchEfiVariables = true;

    boot.tmp.useTmpfs = true;

    zramSwap = {
      enable = true;
      memoryPercent = 30;
    };

    users.groups.${config.user.name} = {};
    users.users.${config.user.name} = {
      isNormalUser = true;
      group = "grae";
      description = "grae ceney";
      extraGroups = ["wheel" "networkmanager" "bluetooth"];
    };
    services.upower.enable = true;
    programs.niri.bar = "waybar";

    system.theme.name = "catppuccin-mocha";
    system.stateVersion = "26.05";
  };
}
