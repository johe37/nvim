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

      -- Highlighting and indent are no longer enabled via a config table;
      -- start them per-buffer in a FileType autocmd.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = langs,
        callback = function(args)
          -- Old config disabled JSON highlighting; preserve that.
          if args.match ~= "json" then
            vim.treesitter.start()
          end
          vim.bo[args.buf].indentexpr =
            "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
