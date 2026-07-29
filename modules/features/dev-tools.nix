{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.dev-tools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [

      # Languages
      odin
      
      cargo
      rustc
      clippy
      
      go
      bun
      python3
      zig
      clang
      sqlite

      # LSP servers
      nixd
      typescript-language-server
      tailwindcss-language-server
      vscode-langservers-extracted
      emmet-language-server
      lua-language-server
      gopls
      golangci-lint
      rust-analyzer
      basedpyright
      ruff
      clang-tools
      eslint
      svelte-language-server
      vue-language-server
      dockerfile-language-server
      docker-compose-language-service
      yaml-language-server
      taplo
      bash-language-server
      cmake-language-server
      ols
      zls

      # Formatters
      alejandra
      prettier
      stylua
      shfmt
      yamlfmt

      # Build / treesitter deps
      gcc
      gnumake
      nodejs

      # Dev tools
      ripgrep
      fd
      git
      lazygit
      tree-sitter
      tmux
      curl
      fzf
      direnv
      git-lfs
      nix-output-monitor
    ];
  };
}
