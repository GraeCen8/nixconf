{ self, inputs, ... }: {
  flake.nixosModules.noctalia = { config, pkgs, lib, ... }: {
    options.services.noctalia = {
      enable = lib.mkEnableOption "noctalia shell bar";
    };
  };

  perSystem = { pkgs, ... }: {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings = 
        (builtins.fromJSON
            (builtins.readFile ./noctalia.json));
    };
  };
}
