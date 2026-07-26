{ self, inputs, ... }: {
  flake.nixosModules.helix = { pkgs, config, lib, ... }:
  let
    themes = import ../../../themes-data.nix;
    theme = themes.${config.system.theme.name};
    helixConfig = pkgs.writeText "config.toml" ''
      theme = "${theme.helix-theme}"

      [editor]
      cursorline = true
      scrolloff = 8
      bufferline = "multiple"
      idle-timeout = 0
      rulers = [100]
      true-color = true
      completion-replace = true
      trim-trailing-whitespace = true
      insert-final-newline = true
      auto-pairs = true
      popup-border = "all"
      end-of-line-diagnostics = "hint"

      [editor.smart-tab]
      enable = true

      [editor.statusline]
      left = ["mode", "spinner", "file-name", "file-modification-indicator"]
      right = ["diagnostics", "position", "file-encoding"]

      [editor.whitespace.render]
      space = "none"
      tab = "all"
      nbsp = "all"

      [editor.indent-guides]
      render = true
      character = "│"

      [editor.soft-wrap]
      enable = true

      [editor.lsp]
      display-inlay-hints = true
      inlay-hints-length-limit = 15

      [editor.cursor-shape]
      insert = "bar"
      select = "underline"

      [keys.normal]
      C-h = "jump_view_left"
      C-j = "jump_view_down"
      C-k = "jump_view_up"
      C-l = "jump_view_right"
      C-space = "goto_word"
      C-g = [":new", ":insert-output lazygit", ":buffer-close!", ":redraw"]

      [keys.insert]
      C-h = "jump_view_left"
      C-j = "jump_view_down"
      C-k = "jump_view_up"
      C-l = "jump_view_right"
      C-space = "goto_word"
      C-g = [":new", ":insert-output lazygit", ":buffer-close!", ":redraw"]
      "C-." = "completion"
      j = { k = "normal_mode" }

      [keys.select]
      C-h = "jump_view_left"
      C-j = "jump_view_down"
      C-k = "jump_view_up"
      C-l = "jump_view_right"
      C-space = "goto_word"
      C-g = [":new", ":insert-output lazygit", ":buffer-close!", ":redraw"]
    '';
    helixLanguages = pkgs.writeText "languages.toml" (builtins.readFile ./config/languages.toml);
  in {
    environment.etc."helix/config.toml".source = helixConfig;
    environment.etc."helix/languages.toml".source = helixLanguages;

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
