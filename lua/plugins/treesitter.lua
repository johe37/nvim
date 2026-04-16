return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- The new (main-branch) API does not support lazy-loading.
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local langs = {
        "bash",
        "lua",
        "vim",
        "vimdoc",
        "python",
        "javascript",
        "typescript",
        "html",
        "css",
        "json",
        "yaml",
        "markdown",
        "c",
        "diff",
      }

      -- Asynchronously install/update parsers for the languages above.
      -- No-op if already installed.
      require("nvim-treesitter").install(langs)
    end,
  },
}
