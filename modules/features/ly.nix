{ self, inputs, ... }: {
  flake.nixosModules.ly = { pkgs, lib, config, ... }: {
    services.displayManager.ly = {
      enable = true;
    };

    security.polkit.enable = true;

    environment.systemPackages = with pkgs; [ ly ];
  };
}
