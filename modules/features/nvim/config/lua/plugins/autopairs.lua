return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    local autopairs = require "nvim-autopairs"
    autopairs.setup { check_ts = true }

    local html_filetypes = {
      html = true,
      typescriptreact = true,
      javascriptreact = true,
      svelte = true,
      astro = true,
      vue = true,
      xml = true,
      heex = true,
    }

    local group = vim.api.nvim_create_augroup("autopairs-html-tags", { clear = true })
    vim.api.nvim_create_autocmd("InsertCharPre", {
      group = group,
      pattern = "*",
      callback = function()
        if vim.v.char ~= ">" then
          return
        end
        if not html_filetypes[vim.bo.filetype] then
          return
        end
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        local before = line:sub(1, col)
        local tag = before:match "<([%w][%w%-]*)[^>]*$"
        if not tag then
          return
        end
        vim.schedule(function()
          local row, c = unpack(vim.api.nvim_win_get_cursor(0))
          local close_tag = "</" .. tag .. ">"
          vim.api.nvim_buf_set_text(0, row - 1, c, row - 1, c, { close_tag })
          vim.api.nvim_win_set_cursor(0, { row, c })
        end)
      end,
    })
  end,
}
