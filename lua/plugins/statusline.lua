return {
  "nvim-mini/mini.statusline",
  version = "*",
  config = function()
    -- Mode is drawn in the statusline. The command-line "-- INSERT --" would repeat it.
    vim.opt.showmode = false

    local function active()
      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
      -- Empty icon skips the "Git" / "Diag" words mini uses when icons are off.
      local git = MiniStatusline.section_git({ trunc_width = 40, icon = "" })
      local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75, icon = "" })
      local filename = MiniStatusline.section_filename({ trunc_width = 140 })
      local location = MiniStatusline.section_location({ trunc_width = 75 })

      return MiniStatusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
        "%<",
        { hl = "MiniStatuslineFilename", strings = { filename } },
        "%=",
        { hl = mode_hl, strings = { location } },
      })
    end

    require("mini.statusline").setup({
      use_icons = false,
      content = { active = active },
    })
  end,
}
