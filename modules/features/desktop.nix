{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.desktop = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.themes
      self.nixosModules.dev-tools
      self.nixosModules.nvim
      self.nixosModules.helix
      self.nixosModules.alacritty
      self.nixosModules.niri
      self.nixosModules.ly
      self.nixosModules.fuzzel
      self.nixosModules.waybar
      self.nixosModules.mako
      self.nixosModules.wallpaper
      self.nixosModules.fish
      self.nixosModules.noctalia
      self.nixosModules.lock
      self.nixosModules.homeManager
      self.nixosModules.web
      self.nixosModules.power
      self.nixosModules.wlogout
      self.nixosModules.misc
    ];

    programs.dconf.enable = true;

    services.printing.enable = true;
    services.gvfs.enable = true;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    services.libinput.enable = true;

    virtualisation.docker.enable = true;

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
  };
}
