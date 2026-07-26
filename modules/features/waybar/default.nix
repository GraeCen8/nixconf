{ self, inputs, ... }: {
  flake.nixosModules.waybar = { pkgs, lib, config, ... }:
  let
    mediaScripts = pkgs.stdenv.mkDerivation {
      name = "waybar-media-scripts";
      src = ./media;
      installPhase = ''
        mkdir -p $out
        cp *.sh $out/
        chmod +x $out/*.sh
      '';
    };

    waybarConfig = pkgs.writeText "config.jsonc" (builtins.replaceStrings
      [ "@mediaScripts@" ]
      [ "${mediaScripts}" ]
      (builtins.readFile ./config.jsonc)
    );

    waybarStyle = pkgs.writeText "style.css" (builtins.readFile ./style.css);
  in {
    environment.systemPackages = with pkgs; [ waybar pavucontrol ];
    environment.etc."xdg/waybar/config.jsonc".source = waybarConfig;
    environment.etc."xdg/waybar/style.css".source = waybarStyle;
  };
}
