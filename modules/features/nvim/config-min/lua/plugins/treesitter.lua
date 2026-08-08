return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },

    config = function()
      require("nvim-treesitter").install({
        "c", "cpp", "rust", "zig", "go", "odin", "lua",
        "html", "css", "javascript", "typescript", "tsx", "svelte", "astro",
        "python", "nix", "json", "yaml", "toml", "bash", "markdown", "markdown_inline",
      })

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(
            vim.bo[args.buf].filetype
          )

          if not lang then
            return
          end

          pcall(vim.treesitter.start, args.buf, lang)
        end,
      })
    end,
  },
}
