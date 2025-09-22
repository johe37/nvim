return {
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 300,
          virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end

          map('n', '<leader>gb', gs.blame_line, 'Git Blame current line')
          map('n', '<leader>gp', gs.preview_hunk, 'Git Preview hunk')
          map('n', '<leader>gn', gs.next_hunk, 'Git Next hunk')
          map('n', '<leader>gN', gs.prev_hunk, 'Git Previous hunk')
          map('n', '<leader>gr', gs.reset_hunk, 'Git Reset hunk')
          map('n', '<leader>gs', gs.stage_hunk, 'Git Stage hunk')
          map('n', '<leader>gu', gs.undo_stage_hunk, 'Git Undo stage hunk')
        end
      }
    end
  }
}
