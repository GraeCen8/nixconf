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
      self.nixosModules.gaming
      self.nixosModules.noctalia
      self.nixosModules.homeManager
    ];

    services.xserver.enable = true;

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    services.printing.enable = true;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    services.libinput.enable = true;

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
  };
}
