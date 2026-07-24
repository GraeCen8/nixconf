require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "clangd",
  "vtsls",
  "gopls",
  "ols",
  "svelte",
  "tailwindcss",
  "eslint",
  "jsonls",
  "astro-language-server",
  "emmet_language_server",
  "volar",
}
vim.lsp.enable(servers)
