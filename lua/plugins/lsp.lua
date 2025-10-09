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

    -- ========================
    -- Global diagnostic keymaps
    -- ========================
    local global_opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<leader>ds", function()
      vim.diagnostic.open_float()
    end, { desc = "Show diagnostic for current line", noremap = true, silent = true }, global_opts)

    vim.keymap.set("n", "dp", vim.diagnostic.goto_prev,
      { desc = "Go to previous diagnostic", noremap = true, silent = true }, global_opts)

    vim.keymap.set("n", "dn", vim.diagnostic.goto_next,
      { desc = "Go to next diagnostic", noremap = true, silent = true }, global_opts)

    vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, 
      { desc = "Open diagnostic in location list", noremap = true, silent = true }, global_opts)

    -- ========================
    -- Function called on LSP attach
    -- ========================
    local on_attach = function(_, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }
      local keymap = vim.keymap.set

      -- LSP keymaps
      keymap("n", "K", vim.lsp.buf.hover,
        { desc = "Show hover documentation", buffer = bufnr, noremap = true, silent = true }, opts)

      keymap("n", "gd", vim.lsp.buf.definition, 
        { desc = "Go to definition", buffer = bufnr, noremap = true, silent = true }, opts)

      keymap("n", "gr", vim.lsp.buf.references,
        { desc = "List references", buffer = bufnr, noremap = true, silent = true }, opts)

      keymap("n", "<leader>rn", vim.lsp.buf.rename,
        { desc = "Rename symbol", buffer = bufnr, noremap = true, silent = true }, opts)

      keymap("n", "<leader>ca", vim.lsp.buf.code_action,
        { desc = "Code actions", buffer = bufnr, noremap = true, silent = true }, opts)

      keymap("i", "<C-h>", vim.lsp.buf.signature_help,
        { desc = "Signature help", buffer = bufnr, noremap = true, silent = true }, opts)
    end

    -- Initialize UI and Mason
    require("fidget").setup({})
    mason.setup()

    -- Custom server configurations
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


      pyright = function()
        local venv = os.getenv("VIRTUAL_ENV")
        local python_path = venv and (venv .. "/bin/python") or vim.fn.exepath("python")

        lspconfig.pyright.setup({
          capabilities = capabilities,
          on_attach = on_attach,
          settings = {
            python = {
              pythonPath = python_path,
            },
          },
        })
      end,

      ts_ls = function()
        lspconfig.ts_ls.setup({
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            -- Disable ts_ls formatting if using external formatter (prettier/eslint/biome)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            on_attach(client, bufnr)
          end,
          -- Explicitly set filetypes (add any custom ones like .js.ejs)
          filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "javascript.ejs" },
          -- Settings for auto-imports
          settings = {
            javascript = {
              suggest = { autoImports = true },
            },
            typescript = {
              suggest = { autoImports = true },
            },
          },
        })
      end
    }


    -- Setup LSPs via mason-lspconfig
    mason_lspconfig.setup({
      ensure_installed = {
        "ansiblels",
        "jsonls",
        "pyright",
        "ts_ls"
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

