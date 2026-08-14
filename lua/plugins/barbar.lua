return {
  {
    'romgrk/barbar.nvim',
    event = "VimEnter",
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {
      icons = {
        filetype = { enabled = false },
      },
    },
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
  },
}
