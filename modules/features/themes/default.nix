{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.themes = {
    config,
    lib,
    ...
  }: let
    themes = import ../../../themes-data.nix;
  in {
    options.system.theme = {
      name = lib.mkOption {
        type = lib.types.enum (builtins.attrNames themes);
        default = "nord";
        description = "System-wide color theme";
      };
    };

    config = {
      environment.variables.SYSTEM_THEME = config.system.theme.name;
    };
  };
}
