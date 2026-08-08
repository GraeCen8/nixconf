return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  opts = {},
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
  keys = {
    { "-", "<cmd>Oil<CR>", desc = "oil file tree" },
  },
}
