{ self, inputs, ... }: {
  flake.nixosModules.helix = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      helix

      nixd
      nil
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
      svelte-language-server
      vue-language-server
      dockerfile-language-server-nodejs
      docker-compose-language-service
      yaml-language-server
      taplo
      bash-language-server
      cmake-language-server
      ols
      zls
      zig

      alejandra
      prettier
      stylua
      shfmt
      yamlfmt

      ripgrep
      fd
      git
      lazygit
      tree-sitter

      gcc
      nodejs
    ];
  };
}
