return {
  {
    'nvim-pack/nvim-spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>sr', function() require('spectre').open() end, desc = 'Search and Replace in Project' },
      { '<leader>sw', function() require('spectre').open_visual({ select_word = true }) end, desc = 'Search current word' },
      { '<leader>sw', function() require('spectre').open_visual() end, mode = 'v', desc = 'Search selected text' },
      { '<leader>sp', function() require('spectre').open_file_search({ select_word = true }) end, desc = 'Search in current file' },
    },
    config = function()
      require('spectre').setup()
    end,
  }
}
