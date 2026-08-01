{ self, inputs, ... }: {
  flake.nixosModules.ly = { config, ... }:
  let
    themes = import ../../themes-data.nix;
    theme = themes.${config.system.theme.name};
    c = theme.colors;
  in {
    services.displayManager.ly = {
      enable = true;
      settings = {
        bg_color = c.bg;
        hide_borders = true;
      };
    };

    security.polkit.enable = true;
  };
}
