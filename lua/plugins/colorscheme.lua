return {
  {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    config = function()
      vim.o.background = "dark" -- or "light" if you prefer
      require("vscode").setup({
        transparent = false,
        italic_comments = true,
      })
      vim.cmd("colorscheme vscode")
    end,
  },
}

-- return {
--   {
--     "folke/tokyonight.nvim",
--     priority = 1000, -- Load before other plugins
--     config = function()
--       require("tokyonight").setup({
--         style = "night", -- Choose from: "storm", "night", "moon", "day"
--         transparent = false,
--         terminal_colors = true,
--         styles = {
--           comments = { italic = false },
--           keywords = { italic = false },
--         },
--       })
--       vim.cmd.colorscheme("tokyonight-night")
--     end,
--   },
-- }
