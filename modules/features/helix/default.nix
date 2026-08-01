{ self, inputs, ... }: {
  flake = {
    nixosModules.helix = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [ helix ];
    };

    homeManagerModules.helix = { config, pkgs, lib, systemTheme, ... }: let
      themes = import ../../../themes-data.nix;
      helixTheme = themes.${systemTheme}.helix-theme or "nord";
      helixConfig = pkgs.runCommand "helix-config" {} ''
        cp -r ${./config}/. $out/
        chmod -R u+w $out
        { echo 'theme = "${helixTheme}"'
          cat ${./config}/config.toml
        } > $out/config.toml
      '';
    in {
      home.packages = with pkgs; [ helix ];
      home.sessionVariables.EDITOR = lib.mkDefault "hx";

      xdg.configFile."helix" = {
        source = helixConfig;
        recursive = true;
      };
    };
  };
}
