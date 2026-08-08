local builtin = require('telescope.builtin')

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", builtin.find_files,  desc = "Find files" },
      { "<leader>/",  builtin.live_grep,   desc = "Live grep" },
      { "<leader>fb", builtin.buffers,     desc = "Buffers" },
      { "<leader>fh", builtin.help_tags,   desc = "Help tags" },
      { "<leader>fg", builtin.git_files,   desc = "Git files" },
      { "<leader>fd", builtin.diagnostics, desc = "Diagnostics" }
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      pcall(require("telescope").load_extension, "fzf")
    end,
  },
}
