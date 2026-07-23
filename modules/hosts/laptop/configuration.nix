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
    ];

    nix.settings.experimental-features = ["nix-command" "flakes"];

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "nixos"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    networking.networkmanager.enable = true;

    time.timeZone = "Europe/London";

    i18n.defaultLocale = "en_GB.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };

    users.users."grae" = {
      isNormalUser = true;
      description = "grae ceney";
      extraGroups = ["networkmanager" "wheel"];
      packages = with pkgs; [
        vim
        wget
        neovim
        git
        gh
        lazygit
        opencode
        librewolf
      ];
    };

    programs.firefox.enable = true;
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      wget
      git
    ];

    system.stateVersion = "26.05"; # don't change
  };
}
