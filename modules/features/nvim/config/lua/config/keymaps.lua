-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map({ "n", "v", "x" }, ";", ":")

map({ "n", "v", "x" }, "<C-1>", "\\")
map({ "n", "v", "x" }, "<C-2>", "\\n")
map({ "n", "v", "x" }, "<C-3>", "|")
