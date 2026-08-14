local cmp = require("cmp")
local luasnip = require("luasnip")

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
  performance = {
    debounce = 60,
    fetching_timeout = 200,
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip", keyword_length = 2 },
  }, {
    {
      name = "buffer",
      keyword_length = 3,
      option = {
        get_bufnrs = function()
          return { vim.api.nvim_get_current_buf() }
        end,
      },
    },
  }),
  enabled = function()
    if vim.b.large_file then
      return false
    end
    -- Disable completion for JSON files to avoid lag on minified files
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })
    if filetype == "json" then
      return false
    end
    local context = require("cmp.config.context")
    return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
  end,
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
