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
    wallpapers = pkgs.stdenv.mkDerivation {
      name = "my-wallpapers";
      src = ./walls;
      installPhase = ''
        mkdir -p $out
        cp -r . $out/
      '';
    };
  in {
    packages.wallpapers = wallpapers;
  };

  flake.nixosModules.wallpaper = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) system;
    themeName = config.system.theme.name;
    themeWpDir = "${self.packages.${system}.wallpapers}/${themeName}";

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
