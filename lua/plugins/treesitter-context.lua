return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "BufReadPost",
    main = "treesitter-context",
    config = function()
      require("treesitter-context").setup({
        enable = true,           -- Enable this plugin
        max_lines = 3,           -- How many lines the context window should show
        min_window_height = 0,   -- Minimum editor height to enable context
        line_numbers = true,     -- Show line numbers in context window
        multiline_threshold = 20,-- Max lines for a node to be displayed
        trim_scope = 'outer',    -- 'inner' or 'outer'
        mode = 'cursor',         -- 'cursor' or 'topline'
        separator = "─",
        zindex = 20,             -- Z-index of the context window
        on_attach = nil          -- Custom callback when attaching
      })
      -- Default group links to FloatBorder, which is body text. Match splits instead.
      vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { link = "WinSeparator" })
    end,
  },
}
