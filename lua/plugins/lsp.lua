return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "j-hui/fidget.nvim",
  },

  config = function()
    local lspconfig = require("lspconfig")
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local cmp = require("cmp")
    local cmp_lsp = require("cmp_nvim_lsp")
    local luasnip = require("luasnip")

    local capabilities = cmp_lsp.default_capabilities()

    local on_attach = function(_, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }
      local keymap = vim.keymap.set

      keymap("n", "K", vim.lsp.buf.hover, opts) -- Hover docs
      keymap("n", "gd", vim.lsp.buf.definition, opts) -- Go to definition
      keymap("n", "gr", vim.lsp.buf.references, opts) -- References
      keymap("n", "<leader>rn", vim.lsp.buf.rename, opts) -- Rename
      keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- Code actions
      keymap("i", "<C-h>", vim.lsp.buf.signature_help, opts) -- Signature help
      keymap("n", "<leader>e", vim.diagnostic.open_float, opts)
    end

    -- Initialize UI and LSP installer
    require("fidget").setup({})
    mason.setup()

    -- Define custom server configurations
    local custom_servers = {
      lua_ls = function()
        lspconfig.lua_ls.setup({
          capabilities = capabilities,
          on_attach = on_attach,
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim", "it", "describe", "before_each", "after_each" },
              },
            },
          },
        })
      end,
    }

    -- Setup LSPs via mason-lspconfig
    mason_lspconfig.setup({
      ensure_installed = {
        "ansiblels",
        "jsonls",
        "pyright",
      },
      handlers = setmetatable(custom_servers, {
        __index = function()
          return function(server_name)
            lspconfig[server_name].setup({
              capabilities = capabilities,
              on_attach = on_attach,
            })
          end
        end,
      }),
    })

    -- Completion engine config
    local cmp_select = { behavior = cmp.SelectBehavior.Select }
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<S-Tab>"] = cmp.mapping.select_prev_item(cmp_select),
        ["<Tab>"] = cmp.mapping.select_next_item(cmp_select),
        ["<Enter>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
      }, {
        { name = "buffer" },
      }),
    })

    -- Diagnostic UI styling
    vim.diagnostic.config({
      float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    })
  end,
}
