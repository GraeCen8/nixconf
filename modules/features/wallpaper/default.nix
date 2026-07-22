{
  self,
  inputs,
  ...
}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.defaultWallpaper = pkgs.runCommand "nord-wallpaper" {
      buildInputs = [ pkgs.imagemagick ];
    } ''
      mkdir -p $out
      ${pkgs.imagemagick}/bin/convert -size 1920x1080 \
        gradient:'#2E3440'-'#3B4252' \
        $out/wallpaper.png
    '';
  };

  flake.nixosModules.wallpaper = {
    pkgs,
    lib,
    config,
    ...
  }:
  let
    inherit (pkgs.stdenv.hostPlatform) system;
    defaultWallpaper = self.packages.${system}.defaultWallpaper;

    wallpaperSet = pkgs.writeShellScriptBin "wallpaper-set" ''
      set -e
      if [ -z "$1" ]; then
        echo "Usage: wallpaper-set <path-to-image>"
        echo ""
        echo "Tip: download some wallpapers to ~/Pictures/Wallpapers/ and run:"
        echo "  wallpaper-set ~/Pictures/Wallpapers/your-image.jpg"
        exit 1
      fi
      pkill swaybg 2>/dev/null || true
      sleep 0.2
      ${pkgs.swaybg}/bin/swaybg --image "$1" --mode fill &
      echo "wallpaper $1" > /tmp/current-wallpaper
      echo "Wallpaper set to: $1"
    '';

    wallpaperInit = pkgs.writeShellScriptBin "wallpaper-init" ''
      ${wallpaperSet}/bin/wallpaper-set "${defaultWallpaper}/wallpaper.png"
    '';
  in {
    environment.systemPackages = with pkgs; [
      swaybg
      wallpaperSet
      wallpaperInit
    ];
  };
}
