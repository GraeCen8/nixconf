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
    themes = import ../themes/themes.nix;
  in {
    packages.defaultWallpaper = pkgs.runCommand "nord-wallpaper" {
      buildInputs = [ pkgs.imagemagick ];
    } ''
      mkdir -p $out
      ${pkgs.imagemagick}/bin/convert -size 1920x1080 \
        gradient:'#2E3440'-'#3B4252' \
        $out/wallpaper.png
    '';

    packages.themeWallpapers = pkgs.symlinkJoin {
      name = "theme-wallpapers";
      paths = lib.mapAttrsToList (name: theme: pkgs.runCommand "${name}-wallpaper" {
        buildInputs = [ pkgs.imagemagick ];
      } ''
        mkdir -p $out
        ${pkgs.imagemagick}/bin/convert -size 1920x1080 \
          gradient:'${theme.colors.bg}'-'${theme.colors.bg-alt}' \
          $out/wallpaper.png
      '') themes;
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
    themes = import ../themes/themes.nix;
    currentTheme = themes.${config.system.theme.name};
    wallpapersDir = self.packages.${system}.wallpapers;
    defaultWallpaper = self.packages.${system}.defaultWallpaper;

    wallpaperSet = pkgs.writeShellScriptBin "wallpaper-set" ''
      WALLPAPER_DIR="${wallpapersDir}"
      set -e
      if [ -z "$1" ]; then
        echo "Usage: wallpaper-set <path-to-image>"
        echo ""
        echo "  wallpaper-set /path/to/image.jpg"
        exit 1
      fi
      pkill swaybg 2>/dev/null || true
      sleep 0.2
      swaybg --image "$1" --mode fill &
      echo "$1" > /tmp/current-wallpaper
    '';

    wallpaperNext = pkgs.writeShellScriptBin "wallpaper-next" ''
      WALLPAPER_DIR="${wallpapersDir}"
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
      notify-send "wallpaper-next" "$TARGET"
    '';

    wallpaperInit = pkgs.writeShellScriptBin "wallpaper-init" ''
      DEFAULT="${defaultWallpaper}/wallpaper.png"
      pkill swaybg 2>/dev/null || true
      sleep 0.2
      swaybg --image "$DEFAULT" --mode fill &
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
