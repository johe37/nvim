local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local cmp_lsp = require("cmp_nvim_lsp")

local capabilities = cmp_lsp.default_capabilities()

-- ========================
-- Global diagnostic keymaps
-- ========================
vim.keymap.set("n", "<leader>dc", vim.diagnostic.open_float,
  { desc = "Show diagnostic for current line" })
vim.keymap.set("n", "dp", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "dn", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist,
  { desc = "Open diagnostic in location list" })
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setqflist,
  { desc = "Send all diagnostics to quickfix" })
vim.keymap.set("n", "<leader>dt", function()
  local enabled = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = not enabled })
end, { desc = "Toggle diagnostic virtual text" })
vim.keymap.set("n", "<leader>de", function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
end, { desc = "Go to next error" })
vim.keymap.set("n", "<leader>dE", function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
end, { desc = "Go to previous error" })

-- ========================
-- Global LSP keymaps
-- ========================
vim.keymap.set("n", "K", vim.lsp.buf.hover,
  { desc = "Show hover documentation" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition,
  { desc = "Go to definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references,
  { desc = "List references" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,
  { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,
  { desc = "Code actions" })
vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help,
  { desc = "Signature help" })

-- on_attach callback (currently just a placeholder)
local on_attach = function(_, bufnr)
end

-- Initialize UI and Mason
require("fidget").setup({})
mason.setup()

-- Install the LSP server binaries via Mason. Configuration and enablement
-- below uses Neovim's native vim.lsp.config / vim.lsp.enable APIs.
local servers = { "ansiblels", "jsonls", "pyright", "ts_ls" }

mason_lspconfig.setup({
  ensure_installed = servers,
})

-- Defaults applied to every LSP server
vim.lsp.config("*", {
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Per-server overrides
local venv = os.getenv("VIRTUAL_ENV")
local python_path = venv and (venv .. "/bin/python") or vim.fn.exepath("python")
vim.lsp.config("pyright", {
  settings = {
    python = {
      pythonPath = python_path,
    },
  },
})

vim.lsp.config("ts_ls", {
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "javascript.ejs" },
  settings = {
    javascript = { suggest = { autoImports = true } },
    typescript = { suggest = { autoImports = true } },
  },
})

vim.lsp.enable(servers)
