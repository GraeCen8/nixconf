require("nvchad.configs.lspconfig").defaults()

local servers = {
  html = { cmd = { "vscode-html-language-server", "--stdio" } },
  cssls = { cmd = { "vscode-css-language-server", "--stdio" } },
  clangd = { cmd = { "clangd" } },
  vtsls = { cmd = { "typescript-language-server", "--stdio" } },
  gopls = { cmd = { "gopls" } },
  svelte = { cmd = { "svelteserver", "--stdio" } },
  tailwindcss = { cmd = { "tailwindcss-language-server", "--stdio" } },
  eslint = { cmd = { "vscode-eslint-language-server", "--stdio" } },
  jsonls = { cmd = { "vscode-json-language-server", "--stdio" } },
  emmet_language_server = { cmd = { "emmet-language-server", "--stdio" } },
  volar = { cmd = { "vue-language-server", "--stdio" } },
  nixd = { cmd = { "nixd" } },
}

for server, opts in pairs(servers) do
  vim.lsp.config(server, opts)
end

vim.lsp.enable(vim.tbl_keys(servers))
