{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.misc = {
    pkgs,
    lib,
    config,
    ...
  }: {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        fuse3
        alsa-lib
        at-spi2-atk
        at-spi2-core
        cups
        libdrm
        libGL
        libxkbcommon
        openssl
        pango
        pipewire
        wayland
        libx11
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxi
        libxrender
        libxtst
        libxcb
        libxcb-image
        libxcb-keysyms
        libxcb-render-util
        libgcc.lib
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
