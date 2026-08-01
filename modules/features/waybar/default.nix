{ self, inputs, ... }: {
  flake.nixosModules.waybar = { pkgs, lib, config, ... }:
  let
    themes = import ../../../themes-data.nix;
    theme = themes.${config.system.theme.name};
    c = theme.colors;

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

    waybarStyle = pkgs.writeText "style.css" ''
      @define-color highlight ${c.accent};
      @define-color dark-9 ${c.bg};
      @define-color dark-8 ${c.bg-alt};
      @define-color dark-7 ${c.bg-light};
      @define-color dark-6 ${c.bg-lighter};
      @define-color dark-5 ${c.info};

      * {
        font-family: ${themes.font.family} Propo;
        font-size: 13px;
      }

      window#waybar {
        background-color: transparent;
        color: ${c.fg};
      }

      .modules-left,
      .modules-center,
      .modules-right {
        background: @dark-9;
        border: 1px solid ${c.border};
        border-radius: 12px;
        margin: 6px 5px;
        padding: 2px 4px;
      }

      #workspaces button {
        padding: 1px;
        margin: 2px 0px 2px 2px;
        background: transparent;
        border-radius: 2px;
        color: ${c.fg};
      }

      #workspaces button.active {
        background: @highlight;
        color: ${c.bg};
        font-weight: 700;
        border-radius: 12px;
      }

      #submap,
      #battery,
      #bluetooth,
      #network,
      #cpu,
      #memory,
      #volume {
        border-radius: 3px;
        padding: 1px 5px;
        background: @dark-8;
        margin: 2px 3px 2px 0px;
      }

      #submap,
      #workspaces button.urgent {
        background: ${c.error};
        color: ${c.bg};
      }

      #pulseaudio-slider {
        padding: 0px;
        margin: 0px;
        margin-left: 2px;
      }

      #pulseaudio-slider slider {
        all: unset;
        min-height: 0;
        min-width: 0;
        opacity: 0;
        background-image: none;
        border: none;
        box-shadow: none;
      }

      #pulseaudio-slider trough {
        min-height: 5px;
        min-width: 40px;
        border-radius: 3px;
        background: @dark-7;
      }

      #pulseaudio-slider highlight {
        min-width: 5px;
        border-radius: 3px;
        background: @highlight;
      }

      #media {
        color: ${c.success};
        margin: 3px 0px 3px 8px;
      }

      #custom-media-animation {
        font-size: 10px;
        margin-right: 4px;
      }

      #custom-media-now-playing {
        margin-right: 4px;
      }

      #custom-media-time {
        color: @dark-5;
        font-size: 10px;
      }

      tooltip {
        background: @dark-9;
        border-radius: 5px;
      }

      tooltip label {
        color: ${c.fg};
      }
    '';
  in {
    environment.systemPackages = with pkgs; [ waybar pavucontrol zscroll wifitui bluetui ];
    environment.etc."xdg/waybar/config.jsonc".source = waybarConfig;
    environment.etc."xdg/waybar/style.css".source = waybarStyle;
  };
}
