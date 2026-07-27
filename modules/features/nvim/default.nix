{ self, inputs, ... }:
{
  flake.nixosModules.nvim = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      neovim
    ];
  };
}
