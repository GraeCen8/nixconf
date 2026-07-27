{ self, inputs, ... }: {
  flake.nixosModules.ly = { ... }: {
    services.displayManager.ly = {
      enable = true;
    };

    security.polkit.enable = true;
  };
}
