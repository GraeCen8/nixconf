{ self, inputs, ... }: {
  flake.nixosModules.gaming = { pkgs, lib, config, ... }: {
    programs.steam.enable = true;

    programs.gamemode.enable = true;

    hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
    ];

    environment.systemPackages = with pkgs; [
      gamemode
    ];

    # TODO: add games here later
    # environment.systemPackages = with pkgs; [
    # ];
  };
}
