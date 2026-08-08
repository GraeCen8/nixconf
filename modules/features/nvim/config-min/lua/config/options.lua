
local o = vim.opt

o.number = true
o.relativenumber = true
o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.smartindent = true
o.wrap = false
o.swapfile = false
o.undofile = true
o.clipboard = "unnamedplus"
o.mouse = "a"
o.termguicolors = true
o.signcolumn = "yes"
o.scrolloff = 8
o.ignorecase = true
o.smartcase = true
o.splitright = true
o.splitbelow = true
o.cmdheight = 0
o.timeoutlen = 300

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.hl.on_yank() end })
vim.api.nvim_create_autocmd("BufWritePre", { callback = function() vim.cmd("%s/\\s\\+$//e") end })
