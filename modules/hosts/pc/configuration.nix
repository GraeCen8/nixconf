{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.pcConfig = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.pcHardware
      self.nixosModules.desktop
      self.nixosModules.settings
    ];

    hardware.graphics.enable = true;
    services.xserver.videoDrivers = ["nvidia"];

    # KTMicro KT USB Audio only supports S16_LE; PipeWire fails with
    # "set_hw_params: No space left on device" when probing other formats.
    # High priority.session keeps the headset as the default sink when plugged in.
    services.pipewire.wireplumber.extraConfig."51-ktmicro".monitor.alsa.rules = [
      {
        matches = [
          { "node.name" = "~alsa_output.usb-KTMicro_KT_USB_Audio_*"; }
          { "node.name" = "~alsa_input.usb-KTMicro_KT_USB_Audio_*"; }
        ];
        actions = {
          "update-props" = {
            "api.alsa.format" = [ "S16LE" ];
            "api.alsa.rate" = [ 48000 ];
            "audio.format" = "S16LE";
            "audio.rate" = 48000;
            "priority.session" = [ 5000 ];
          };
        };
      }
    ];

    hardware.nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
    };

    boot.loader.systemd-boot = {
      enable = true;
      consoleMode = "max";
    };
    boot.loader.efi.canTouchEfiVariables = true;

    # Disable if low on RAM
    boot.tmp.useTmpfs = true;

    # Disable if not on a laptop or if CPU is AMD
    services.auto-cpufreq.enable = true;

    zramSwap = {
      enable = true;
      memoryPercent = 30;
    };

    users.groups.${config.user.name} = {};
    users.users.${config.user.name} = {
      isNormalUser = true;
      group = "grae";
      description = "grae ceney";
      extraGroups = ["wheel" "networkmanager"];
    };
    services.upower.enable = true;
    programs.niri.bar = "waybar";

    environment.sessionVariables.XCURSOR_SIZE = "20";

    system.theme.name = "catppuccin-mocha";
    system.stateVersion = "26.05";
  };
}
