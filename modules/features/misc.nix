{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.misc = {
    pkgs,
    ...
  }: {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        openssl
        libGL
        libxkbcommon
        wayland
      ];
    };

    documentation = {
      man = {
        enable = true;
        man-db.enable = true;
      };
      info.enable = true;
      dev.enable = true;
      nixos.enable = false;
    };
  };
}
