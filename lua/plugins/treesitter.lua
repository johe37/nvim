return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- main-branch setup() only accepts install_dir; parsers are installed separately.
      -- install() is async and a no-op when the parser is already present.
      require("nvim-treesitter").install({
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
      })
    end,
  },
}
