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
      options.user.name = lib.mkOption {
        type = lib.types.str;
        default = "grae";
        description = "Primary username";
      };

      config = {
        user.name = "grae";

        nix.settings = {
          experimental-features = ["nix-command" "flakes"];
          max-jobs = "auto";
          cores = 0;
          auto-optimise-store = true;
          extra-substituters = ["https://nix-community.cachix.org"];
          extra-trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
        };

        nix.optimise.automatic = true;

        nix.registry.nixos-config.flake = self;

        nix.gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };

        services.fstrim.enable = true;

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
        ];

        hardware.bluetooth = {
          enable = true;
          powerOnBoot = true;
        };

      };
    };
  };
}
