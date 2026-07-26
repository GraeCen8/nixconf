{
  self,
  inputs,
  ...
}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    themes = import ../../../themes-data.nix;

    mkThemeWallpapers = name: theme: let
      c = theme.colors;
    in pkgs.runCommand "${name}-wallpapers" {
      buildInputs = [ pkgs.imagemagick ];
    } ''
      mkdir -p $out

      # 1: Horizontal gradient (bg → bg-alt)
      ${pkgs.imagemagick}/bin/convert -size 1920x1080 \
        gradient:'${c.bg}'-'${c.bg-alt}' \
        $out/1-horizontal.png

      # 2: Dark to light vertical feel
      ${pkgs.imagemagick}/bin/convert -size 1920x1080 \
        gradient:'${c.bg}'-'${c.bg-light}' \
        -rotate 90 -gravity center -crop 1920x1080+0+0 +repage \
        $out/2-vertical.png

      # 3: Accent-tinted overlay
      ${pkgs.imagemagick}/bin/convert -size 1920x1080 xc:'${c.bg}' \
        -fill '${c.accent}15' -draw "rectangle 0,0 1920,540" \
        -fill '${c.bg-alt}20' -draw "rectangle 0,540 1920,1080" \
        $out/3-overlay.png

      # 4: Radial glow
      ${pkgs.imagemagick}/bin/convert -size 1920x1080 xc:'${c.bg}' \
        -fill '${c.accent}08' -draw "circle 960,540 960,200" \
        -fill '${c.bg-alt}10' -draw "circle 960,540 960,100" \
        $out/4-radial.png
    '';
  in {
    packages.defaultWallpaper = mkThemeWallpapers "default" themes.nord;

    packages.themeWallpapers = pkgs.symlinkJoin {
      name = "theme-wallpapers";
      paths = lib.mapAttrsToList mkThemeWallpapers themes;
    };

    packages.wallpapers = pkgs.stdenv.mkDerivation {
      name = "my-wallpapers";
      src = ./walls;
      installPhase = ''
        mkdir -p $out
        cp -r . $out/
      '';
    };
  };

  flake.nixosModules.wallpaper = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) system;
    themes = import ../../../themes-data.nix;
    themeName = config.system.theme.name;
    themeWpDir = "${self.packages.${system}.themeWallpapers}/${themeName}-wallpapers";

    wallpaperSet = pkgs.writeShellScriptBin "wallpaper-set" ''
      set -e
      if [ -z "$1" ]; then
        echo "Usage: wallpaper-set <path-to-image>"
        exit 1
      fi
      pkill swaybg 2>/dev/null || true
      sleep 0.2
      swaybg --image "$1" --mode fill &
      echo "$1" > /tmp/current-wallpaper
    '';

    wallpaperNext = pkgs.writeShellScriptBin "wallpaper-next" ''
      WALLPAPER_DIR="${themeWpDir}"
      CURRENT=$(cat /tmp/current-wallpaper 2>/dev/null || echo "")

      IDX=0
      CURRENT_IDX=-1
      TARGET=""
      FIRST=""
      while IFS= read -r -d $'\0' f; do
        if [ -z "$FIRST" ]; then
          FIRST="$f"
        fi
        if [ -z "$TARGET" ] && [ "$CURRENT_IDX" -ge 0 ] && [ "$f" != "$CURRENT" ]; then
          TARGET="$f"
        fi
        if [ "$f" = "$CURRENT" ]; then
          CURRENT_IDX=$IDX
        fi
        IDX=$((IDX + 1))
      done < <(find "$WALLPAPER_DIR" -type f \( -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' \) -print0 2>/dev/null)

      if [ "$IDX" -eq 0 ]; then
        notify-send "wallpaper-next" "No wallpapers found"
        exit 1
      fi

      if [ -z "$TARGET" ]; then
        TARGET="$FIRST"
      fi

      pkill swaybg 2>/dev/null || true
      sleep 0.2
      swaybg --image "$TARGET" --mode fill &
      echo "$TARGET" > /tmp/current-wallpaper
      notify-send "wallpaper-next" "$(basename "$TARGET")"
    '';

    wallpaperInit = pkgs.writeShellScriptBin "wallpaper-init" ''
      WALLPAPER_DIR="${themeWpDir}"
      DEFAULT=$(find "$WALLPAPER_DIR" -type f -name '*.png' -print -quit 2>/dev/null)
      if [ -z "$DEFAULT" ]; then
        echo "No theme wallpaper found"
        exit 1
      fi
      pkill swaybg 2>/dev/null || true
      sleep 0.2
      swaybg --image "$DEFAULT" --mode fill &
      echo "$DEFAULT" > /tmp/current-wallpaper
    '';
  in {
    environment.systemPackages = with pkgs; [
      swaybg
      libnotify
      wallpaperSet
      wallpaperNext
      wallpaperInit
    ];
  };
}
