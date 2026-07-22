require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map({ "i", "n", "v", "x" }, "<C-1>", "\\")
map({ "i", "n", "v", "x" }, "<C-2>", "\\n")
map({ "i", "n", "v", "x" }, "<C-3>", "|")

map({ "n", "v", "x" }, "<Space><Space>", "<Leader>ff", { remap = true, desc = "open files" })
map({ "n", "v", "x" }, "-", "<Cmd>Oil<Cr>", { desc = "open oil" })
