return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Find Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "Find Help" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_config = {
            prompt_position = "top",
          },
          sorting_strategy = "ascending",
          winblend = 10,
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
      })
    end,
  },
}

