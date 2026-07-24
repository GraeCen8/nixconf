{ self, inputs, ... }:
{
  flake.nixosModules.nvim = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # LSP servers
      nixd
      typescript-language-server
      vscode-langservers-extracted
      tailwindcss-language-server
      lua-language-server
      gopls
      clang-tools
      eslint
      svelte-language-server
      vue-language-server
      emmet-language-server

      # Formatters
      alejandra
      stylua
      prettier

      # Treesitter / build deps
      gcc
      nodejs

      # Tools
      ripgrep
      fd
      lazygit
      git
    ];
  };
}
