{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.gaming = {
    pkgs,
    lib,
    config,
    ...
  }: {
    config = {
      programs.steam.enable = true;
      programs.steam.gamescopeSession.enable = true;
      programs.steam.gamescopeSession.args = lib.mkIf config.hardware.gpu.nvidia [
        "--rt"
        "--adaptive-sync"
        "--mangoapp"
      ];

      programs.gamemode.enable = true;
      programs.gamemode.settings = lib.mkIf config.hardware.gpu.nvidia {
        cpu.desiredgov = "performance";
        gpu.apply_gpu_optimisations = "accept-responsibility";
      };

      hardware.graphics.enable32Bit = true;
      hardware.graphics.extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
      ];

      environment.systemPackages = with pkgs;
        [
          gamemode
          gamescope
        ]
        ++ lib.optionals config.hardware.gpu.nvidia [
          mangohud
        ];
    };
  };
}
