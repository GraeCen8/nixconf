{
  self,
  inputs,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    deps = with pkgs; [
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
      make
      yarn

      # Tools
      ripgrep
      fd
      lazygit
      git
    ];

    nvimConfigDir = pkgs.runCommand "nvim-config-dir" {} ''
      mkdir -p $out/nvim
      cp ${./config/init.lua} $out/nvim/init.lua
      cp ${./config/.stylua.toml} $out/nvim/.stylua.toml
      cp -r ${./config/lua} $out/nvim/lua
    '';

    nvim =
      pkgs.runCommand "nvim" {
        nativeBuildInputs = [pkgs.makeWrapper];
        passthru = {unwrapped = pkgs.neovim;};
        meta = {
          description = "Neovim with LSP, formatters, and NvChad config";
          mainProgram = "nvim";
        };
      } ''
        mkdir -p $out/bin
        makeWrapper ${pkgs.neovim}/bin/nvim $out/bin/nvim \
          --prefix PATH : ${pkgs.lib.makeBinPath deps} \
          --suffix XDG_CONFIG_DIRS : ${nvimConfigDir}
        cp -r ${pkgs.neovim}/share $out/share
      '';
  in {
    packages.nvim = nvim;
    packages.default = nvim;

    apps.nvim = {
      type = "app";
      program = "${nvim}/bin/nvim";
    };
    apps.default = {
      type = "app";
      program = "${nvim}/bin/nvim";
    };
  };
}
