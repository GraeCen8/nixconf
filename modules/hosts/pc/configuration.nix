{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.pcConfig = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.pcHardware
      self.nixosModules.desktop
      self.nixosModules.settings
    ];

    boot.loader.systemd-boot = {
      enable = true;
      consoleMode = "max";
    };
    boot.loader.efi.canTouchEfiVariables = true;

    # Disable if low on RAM
    boot.tmp.useTmpfs = true;

    # Disable if not on a laptop or if CPU is AMD
    services.auto-cpufreq.enable = true;

    zramSwap = {
      enable = true;
      memoryPercent = 30;
    };

    users.groups.${config.user.name} = {};
    users.users.${config.user.name} = {
      isNormalUser = true;
      group = "grae";
      description = "grae ceney";
      extraGroups = ["wheel" "networkmanager"];
    };
    services.upower.enable = true;
    programs.niri.bar = "waybar";

    system.theme.name = "catppuccin-mocha";
    system.stateVersion = "26.05";
  };
}
