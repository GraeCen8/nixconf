{ self, inputs, ... }: {
  flake = {
    nixosModules.nvim = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [ neovim ];
    };

    homeManagerModules.nvim = { config, pkgs, lib, systemTheme, ... }: let
      colorschemes = {
        nord = {
          plugin = ''{ "shaunsingh/nord.nvim", priority = 1000 }'';
          colorscheme = "nord";
        };
        catppuccin-mocha = {
          plugin = ''{ "catppuccin/nvim", name = "catppuccin", priority = 1000 }'';
          colorscheme = "catppuccin-mocha";
        };
        tokyo-night = {
          plugin = ''{ "folke/tokyonight.nvim", opts = { style = "night" } }'';
          colorscheme = "tokyonight";
        };
        rose-pine = {
          plugin = ''{ "rose-pine/neovim", name = "rose-pine", priority = 1000 }'';
          colorscheme = "rose-pine";
        };
        minimalist = {
          plugin = ''{ "nendix/zen.nvim", priority = 1000, opts = { variant = "dark", transparent = true } }'';
          colorscheme = "zen";
        };
      };
      selected = colorschemes.${systemTheme} or colorschemes.nord;
      colorschemeLua = ''
        return {
          ${selected.plugin},
          { "LazyVim/LazyVim", opts = { colorscheme = "${selected.colorscheme}" } },
        }
      '';
      nvimConfig = pkgs.runCommand "nvim-config" {} ''
        cp -r ${./config}/. $out/
        chmod -R u+w $out
        cat > $out/lua/plugins/colorscheme.lua <<'EOF'
        ${colorschemeLua}
        EOF
      '';
    in {
      home.packages = with pkgs; [ neovim ];
      home.sessionVariables.EDITOR = "nvim";

      xdg.configFile."nvim" = {
        source = nvimConfig;
        recursive = true;
      };
    };
  };
}
