{ self, inputs, ... }: {
  flake.nixosModules.exampleConfig = { config, pkgs, ... }: {
    imports = [
      self.nixosModules.exampleHardware # hardware describing the system
      self.nixosModules.desktop # the desktop
      self.nixosModules.settings # main settings the enabling bluetooth
      # self.nixosModules.gaming # enables gaming related things like steam
      # self.nixosModules.nvidia # enable if you want to enable your nvidia gpu
    ];

    # hardware.gpu.nvidia = true;
    # hardware.gpu.nvidiaOutput = "DP-3"; # per system
    
    hardware.graphics.enable = true;

    # disable if low on RAM but will improve cpu time if on
    boot.tmp.useTmpfs = true;
    
   
    # naming stuff
    networking.hostName = "nixos-example";
    user.name = "grae";
    user.fullName = "grae ceney";

    programs.niri.bar = "waybar"; # what top bar to use. 
    environment.sessionVariables.XCURSOR_SIZE = "20"; # cursor size

    # the theme to use for all apps. 
    # options: "catppuccin-mocha" "nord" "minimalist" "tokyo-night" "rose-pine"
    system.theme.name = "minimalist";

    system.stateVersion = "26.05";
  };
}
