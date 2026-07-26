{ self, inputs, ... }: {
  flake.nixosModules.niri = {
    pkgs,
    lib,
    config,
    ...
  }: let
    themes = import ../../themes-data.nix;
    theme = themes.${config.system.theme.name};
    c = theme.colors;

    baseSettings = {
      "prefer-no-csd" = true;

      "window-rule" = [{
        "geometry-corner-radius" = 8;
        "clip-to-geometry" = true;
      }];

      input = {
        keyboard.xkb.layout = "us";
        "focus-follows-mouse" = _: {};
        touchpad = {
          tap = _: {};
          dwt = _: {};
        };
      };

      layout = {
        gaps = 10;
        border = {
          width = theme.niri.border-width;
          "active-color" = c.border-active;
          "inactive-color" = c.border;
        };
      };

      binds = {
        "Mod+Return".spawn-sh = lib.getExe pkgs.alacritty;
        "Mod+D".spawn-sh = lib.getExe pkgs.fuzzel;
        "Mod+V".spawn-sh = "${lib.getExe pkgs.clipman} pick -t fuzzel";
        "Mod+Tab".spawn-sh = lib.getExe pkgs.librewolf;

        "Mod+n".spawn-sh = "wallpaper-next";
        "Mod+o".toggle-overview = _: {};

        "Mod+i".focus-workspace-up = _: {};
        "Mod+u".focus-workspace-down = _: {};

        "Mod+Shift+Q".quit = _: {};

        "Mod+Escape".spawn-sh = "lock-screen";


        "Mod+F".maximize-column = _: {};
        "Mod+Ctrl+F".fullscreen-window = _: {};
        "Mod+R"."switch-preset-column-width" = _: {};
        "Mod+C".center-column = _: {};
        "Mod+g".toggle-window-floating = _: {};

        "Mod+h".focus-column-left = _: {};
        "Mod+l".focus-column-right = _: {};
        "Mod+k".focus-window-up = _: {};
        "Mod+j".focus-window-down = _: {};

        "Mod+Shift+h".move-column-left = _: {};
        "Mod+Shift+l".move-column-right = _: {};
        "Mod+Shift+k".move-window-up = _: {};
        "Mod+Shift+j".move-window-down = _: {};

        "Print".spawn-sh = "${lib.getExe pkgs.grim} - | ${lib.getExe' pkgs.wl-clipboard "wl-copy"} -t image/png";
        "Shift+Print".spawn-sh = "${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp})\" | ${lib.getExe' pkgs.wl-clipboard "wl-copy"} -t image/png";

        "Mod+1".focus-workspace = 1;
        "Mod+2".focus-workspace = 2;
        "Mod+3".focus-workspace = 3;
        "Mod+4".focus-workspace = 4;
        "Mod+5".focus-workspace = 5;
        "Mod+6".focus-workspace = 6;
        "Mod+7".focus-workspace = 7;
        "Mod+8".focus-workspace = 8;
        "Mod+9".focus-workspace = 9;

        "Mod+Shift+1"."move-window-to-workspace" = 1;
        "Mod+Shift+2"."move-window-to-workspace" = 2;
        "Mod+Shift+3"."move-window-to-workspace" = 3;
        "Mod+Shift+4"."move-window-to-workspace" = 4;
        "Mod+Shift+5"."move-window-to-workspace" = 5;
        "Mod+Shift+6"."move-window-to-workspace" = 6;
        "Mod+Shift+7"."move-window-to-workspace" = 7;
        "Mod+Shift+8"."move-window-to-workspace" = 8;
        "Mod+Shift+9"."move-window-to-workspace" = 9;

        "XF86AudioLowerVolume".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioRaiseVolume".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioMute".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioPlay".spawn-sh = "${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioNext".spawn-sh = "${pkgs.playerctl}/bin/playerctl next";
        "XF86AudioPrev".spawn-sh = "${pkgs.playerctl}/bin/playerctl previous";

        "XF86MonBrightnessDown".spawn-sh = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        "XF86MonBrightnessUp".spawn-sh = "${pkgs.brightnessctl}/bin/brightnessctl set 5%+";

        "Mod+Ctrl+h"."set-column-width" = "-10%";
        "Mod+Ctrl+l"."set-column-width" = "+10%";
        "Mod+Ctrl+j"."set-window-height" = "-10%";
        "Mod+Ctrl+k"."set-window-height" = "+10%";

        "Mod+comma"."consume-window-into-column" = _: {};
        "Mod+period"."expel-window-from-column" = _: {};

        "Mod+Minus"."set-column-width" = "50%";
        "Mod+Equal"."set-column-width" = "100%";

        "Mod+E".spawn-sh = lib.getExe pkgs.nautilus;

        "Mod+Shift+u"."move-column-to-workspace-up" = _: {};
        "Mod+Shift+i"."move-column-to-workspace-down" = _: {};

        "Mod+W".close-window = _: {};
      };
    };

    commonStartup = [
      ["wallpaper-init"]
      ["${lib.getExe pkgs.mako}"]
      ["${lib.getExe pkgs.clipman}" "init" "-t" "mako"]
      ["${lib.getExe pkgs.clipman}" "listen"]
    ];

    mkNiri = barCmd: inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = baseSettings // {
        spawn-at-startup = commonStartup ++ [barCmd];
      };
    };

    myQuickshell = let
      qmlContent = builtins.readFile ./shell.qml;
      themedQml = builtins.replaceStrings
        [
          "property color bg: \"#2e3440\""
          "property color surface: \"#3b4252\""
          "property color dim: \"#4c566a\""
          "property color fg: \"#d8dee9\""
          "property color accent: \"#81a1c1\""
          "property color green: \"#a3be8c\""
          "property color red: \"#bf616a\""
          "property color yellow: \"#ebcb8b\""
        ]
        [
          "property color bg: \"${c.bg}\""
          "property color surface: \"${c.bg-alt}\""
          "property color dim: \"${c.bg-lighter}\""
          "property color fg: \"${c.fg}\""
          "property color accent: \"${c.border-active}\""
          "property color green: \"${c.success}\""
          "property color red: \"${c.error}\""
          "property color yellow: \"${c.warning}\""
        ]
        qmlContent;

      qmlFile = pkgs.writeText "shell.qml" themedQml;
      qmlDir = pkgs.runCommand "quickshell-config" {} ''
        mkdir -p $out
        cp ${qmlFile} $out/shell.qml
      '';
    in pkgs.writeShellScriptBin "my-quickshell" ''
      exec ${lib.getExe pkgs.quickshell} --path ${qmlDir}
    '';

    myNiri-waybar = mkNiri ["${lib.getExe pkgs.waybar}"];
    myNiri-noctalia = mkNiri ["${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.myNoctalia}"];
    myNiri-quickshell = mkNiri ["${lib.getExe myQuickshell}"];
  in {
    options.programs.niri.bar = lib.mkOption {
      type = lib.types.enum [ "waybar" "noctalia" "quickshell" ];
      default = "noctalia";
    };

    config = {
      programs.niri = {
        enable = true;
        package = lib.mkForce {
          waybar = myNiri-waybar;
          noctalia = myNiri-noctalia;
          quickshell = myNiri-quickshell;
        }.${config.programs.niri.bar};
      };

      environment.systemPackages = with pkgs; [
        grim
        slurp
        wl-clipboard
        brightnessctl
        fzf
        playerctl
        xwayland-satellite
        clipman
      ];
    };
  };
}
