return {
  {
    "TimUntersberger/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim", -- Optional but great for visual diffs
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gs", "<cmd>Neogit<cr>", desc = "Open Neogit" },
    },
    config = function()
      require("neogit").setup({
        integrations = {
          diffview = true,
        },
        signs = {
          section = { "", "" },
          item = { "", "" },
        },
      })
    end,
  },
}

