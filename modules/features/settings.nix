# this defines some constantly used stuff in any of my machines like location and
# garbage collection and networking
{
  self,
  inputs,
  ...
}: {
  flake = {
    nixosModules.settings = {
      config,
      pkgs,
      lib,
      ...
    }: {

      nix.settings.experimental-features = ["nix-command" "flakes"];

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      nix.optimise.automatic = true;

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

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

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        wget
        git
      ];
    };
  };
}
