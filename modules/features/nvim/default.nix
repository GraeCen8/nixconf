{ self, inputs, ... }:
{
  flake.nixosModules.nvim = { config, pkgs, lib, ... }:
  let
    nvimDeps = with pkgs; [
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
  in {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    environment.systemPackages = nvimDeps;

    system.activationScripts.nvim-config = let
      home = config.users.users.grae.home;
      cfg = "${home}/.config/nvim";
    in ''
      mkdir -p ${cfg}/lua/configs ${cfg}/lua/plugins
      ln -sf ${./config/init.lua} ${cfg}/init.lua
      ln -sf ${./config/.stylua.toml} ${cfg}/.stylua.toml
      ln -sf ${./config/lua/options.lua} ${cfg}/lua/options.lua
      ln -sf ${./config/lua/autocmds.lua} ${cfg}/lua/autocmds.lua
      ln -sf ${./config/lua/mappings.lua} ${cfg}/lua/mappings.lua
      ln -sf ${./config/lua/chadrc.lua} ${cfg}/lua/chadrc.lua
      ln -sf ${./config/lua/configs/lazy.lua} ${cfg}/lua/configs/lazy.lua
      ln -sf ${./config/lua/configs/lspconfig.lua} ${cfg}/lua/configs/lspconfig.lua
      ln -sf ${./config/lua/configs/conform.lua} ${cfg}/lua/configs/conform.lua
      for f in ${./config/lua/plugins}/*; do
        ln -sf "$f" ${cfg}/lua/plugins/$(basename "$f")
      done
      chown -R grae:users ${cfg}
    '';
  };
}
