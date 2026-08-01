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
    themes = import ../../../themes-data.nix;
    themeName = config.system.theme.name;
    themeWpDir = "${self.packages.${system}.wallpapers}/${themeName}";
    defaultWpFile =
      if config.system.wallpaper.default != null
      then config.system.wallpaper.default
      else (themes.${themeName}.wallpaper or "");

    wallpaperSet = pkgs.writeShellScriptBin "wallpaper-set" ''
      set -e
      if [ -z "$1" ]; then
        echo "Usage: wallpaper-set <path-to-image>"
        exit 1
      fi
      if ! pgrep -x awww-daemon >/dev/null; then
        awww-daemon &
        sleep 0.3
      fi
      awww img "$1" --resize crop --transition-type grow --transition-fps 60
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

      if ! pgrep -x awww-daemon >/dev/null; then
        awww-daemon &
        sleep 0.3
      fi
      awww img "$TARGET" --resize crop --transition-type grow --transition-fps 60
      echo "$TARGET" > /tmp/current-wallpaper
      notify-send "wallpaper-next" "$(basename "$TARGET")"
    '';

    wallpaperInit = pkgs.writeShellScriptBin "wallpaper-init" ''
      WALLPAPER_DIR="${themeWpDir}"
      DEFAULT="${themeWpDir}/${defaultWpFile}"
      if [ ! -f "$DEFAULT" ]; then
        DEFAULT=$(find "$WALLPAPER_DIR" -type f \( -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' \) -print -quit 2>/dev/null)
      fi
      if [ -z "$DEFAULT" ]; then
        echo "No theme wallpaper found"
        exit 1
      fi
      if ! pgrep -x awww-daemon >/dev/null; then
        awww-daemon &
        sleep 0.3
      fi
      awww img "$DEFAULT" --resize crop
      echo "$DEFAULT" > /tmp/current-wallpaper
    '';
  in {
    options.system.wallpaper.default = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default wallpaper file for the current theme (overrides the per-theme default)";
    };

    config.environment.systemPackages = with pkgs; [
      awww
      libnotify
      wallpaperSet
      wallpaperNext
      wallpaperInit
    ];
  };
}
