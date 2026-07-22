{ self, inputs, ... }: {
  flake.nixosModules.waybar = { pkgs, lib, config, ... }:
  let
    waybarConfig = pkgs.writeText "config.jsonc" ''
      {
        "layer": "top",
        "position": "top",
        "height": 28,
        "spacing": 8,
        "modules-left": ["niri/workspaces"],
        "modules-center": ["clock"],
        "modules-right": ["pulseaudio", "network", "battery", "tray"],
        "niri/workspaces": {
          "format": "{index}",
          "show-icons": false
        },
        "clock": {
          "format": "{:%a %d %b  %H:%M}",
          "tooltip-format": "{:%A, %d %B %Y}"
        },
        "pulseaudio": {
          "format": "{icon} {volume}%",
          "format-muted": "",
          "format-icons": {
            "default": ["", "", ""]
          },
          "on-click": "pavucontrol"
        },
        "network": {
          "format-wifi": "",
          "format-ethernet": "",
          "format-disconnected": "",
          "tooltip-format-wifi": "{essid} ({signalStrength}%)"
        },
        "battery": {
          "format": "{icon} {capacity}%",
          "format-icons": ["", "", "", "", ""],
          "format-charging": " {capacity}%",
          "tooltip-format": "{timeTo} remaining"
        },
        "tray": {
          "icon-size": 16,
          "spacing": 4
        }
      }
    '';

    waybarStyle = pkgs.writeText "style.css" ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        min-height: 0;
        margin: 0;
        padding: 0;
      }

      window#waybar {
        background: rgba(46, 52, 64, 0.85);
        color: #d8dee9;
        border-bottom: 2px solid #3b4252;
      }

      #workspaces button {
        padding: 0 6px;
        background: transparent;
        color: #4c566a;
        border-bottom: 2px solid transparent;
        min-width: 24px;
      }

      #workspaces button.active {
        color: #d8dee9;
        border-bottom: 2px solid #81a1c1;
      }

      #workspaces button.urgent {
        color: #bf616a;
        border-bottom: 2px solid #bf616a;
      }

      #clock,
      #pulseaudio,
      #network,
      #battery,
      #tray {
        padding: 0 10px;
      }

      #clock {
        color: #88c0d0;
      }

      #pulseaudio {
        color: #a3be8c;
      }

      #pulseaudio.muted {
        color: #bf616a;
      }

      #network {
        color: #b48ead;
      }

      #network.disconnected {
        color: #bf616a;
      }

      #battery {
        color: #a3be8c;
      }

      #battery.warning {
        color: #ebcb8b;
      }

      #battery.critical {
        color: #bf616a;
      }

      #tray {
        color: #d8dee9;
      }
    '';
  in {
    environment.systemPackages = with pkgs; [ waybar pavucontrol ];
    environment.etc."xdg/waybar/config.jsonc".source = waybarConfig;
    environment.etc."xdg/waybar/style.css".source = waybarStyle;
  };
}
