{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.niri = {
    pkgs,
    lib,
    ...
  }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };

    programs.xwayland.enable = true;

    environment.systemPackages = with pkgs; [
      grim
      slurp
      wl-clipboard
      brightnessctl
      fzf
      playerctl
    ];
  };

  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        "prefer-no-csd" = true;

        input = {
          keyboard.xkb.layout = "us,ua";
          "focus-follows-mouse" = _: {};
          touchpad = {
            tap = _: {};
            dwt = _: {};
          };
        };

        layout = {
          gaps = 10;
          border = {
            width = 0.5;
            "active-color" = "#AAAAAA";
            "inactive-color" = "#4C566A";
          };
        };

        spawn-at-startup = [
          ["${lib.getExe pkgs.swaybg}" "--image" "${self.packages.${pkgs.stdenv.hostPlatform.system}.defaultWallpaper}/wallpaper.png"]
          ["${lib.getExe pkgs.waybar}"]
          ["${lib.getExe pkgs.mako}"]
        ];

        binds = {
          "Mod+Return".spawn-sh = lib.getExe pkgs.alacritty;
          "Mod+D".spawn-sh = lib.getExe pkgs.fuzzel;
          "Mod+Tab".spawn-sh = lib.getExe pkgs.librewolf;

          "Mod+n".spawn-sh = "wallpaper-next";
          "Mod+o".toggle-overview = _: {};

          "Mod+u".focus-workspace-up = _: {};
          "Mod+i".focus-workspace-down = _: {};

          "Mod+W".close-window = _: {};
          "Mod+Shift+Q".quit = _: {};
          "Mod+V".switch-layout = "next";

          "Mod+F".maximize-column = _: {};
          "Mod+Ctrl+F".fullscreen-window = _: {};
          "Mod+R"."switch-preset-column-width" = _: {};
          "Mod+C".center-column = _: {};
          "Mod+g".toggle-window-floating = _: {};

          "Mod+b".spawn-sh = "pkill -SIGUSR1 waybar";

          "Mod+h".focus-column-left = _: {};
          "Mod+l".focus-column-right = _: {};
          "Mod+k".focus-window-up = _: {};
          "Mod+j".focus-window-down = _: {};

          "Mod+Shift+h".move-column-left = _: {};
          "Mod+Shift+l".move-column-right = _: {};
          "Mod+Shift+k".move-window-up = _: {};
          "Mod+Shift+j".move-window-down = _: {};

          "Shift+Tab"."switch-preset-column-width" = _: {};

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
        };
      };
    };
  };
}
