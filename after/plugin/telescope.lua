local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>sa', function()			-- search files including git ignored files and hidden files
  builtin.find_files({
    no_ignore = true,
    hidden = true
  })
end, {})  							
vim.keymap.set('n', '<leader>sg', builtin.git_files, {})  	-- search git files
vim.keymap.set('n', '<leader>gl', builtin.live_grep, {})  	-- grep live
vim.keymap.set('n', '<leader>gs', builtin.grep_string, {})	-- grep strings
vim.keymap.set('n', '<leader>ga', function()			-- grep all
  builtin.live_grep({
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',
      '--no-ignore'
    }
  })
end, {})

-- vim.keymap.set('n', '<C-p>', builtin.git_files, {}) -- uses key binding ctrl + p
-- vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
-- vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
-- vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
