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

      uiScale = lib.mkOption {
        type = lib.types.number;
        default = 1.0;
        description = "Multiplier for font/UI sizes. Set to (primary monitor logical width / 1920) so apps look consistent across machines";
      };
    };

    config = {};
  };
}
