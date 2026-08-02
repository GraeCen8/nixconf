-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map({ "n", "v", "x" }, ";", ":")

map({ "i", "n", "v", "x" }, "<C-1>", "\\")
map({ "i", "n", "v", "x" }, "<C-2>", "\\n")
map({ "i", "n", "v", "x" }, "<C-3>", "|")
