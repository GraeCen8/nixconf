{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.nvidia = {
    pkgs,
    lib,
    config,
    ...
  }: {
    config = lib.mkIf config.hardware.gpu.nvidia {
      services.xserver.videoDrivers = ["nvidia"];

      hardware.nvidia = {
        modesetting.enable = true;
        open = true;
        nvidiaSettings = true;
      };

      boot.kernelParams = [
        "mitigations=off"
        "nmi_watchdog=0"
      ];

      boot.kernel.sysctl."vm.max_map_count" = 1048576;
    };
  };
}
