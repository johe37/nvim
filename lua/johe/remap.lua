-- File Explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)  -- Open file explorer (netrw)

-- Pasting behavior
vim.keymap.set("x", "<leader>p", "\"_dP")       -- Paste over selection without yanking

-- System clipboard yank
vim.keymap.set("n", "<leader>y", "\"+y")        -- Yank to system clipboard (normal mode)
vim.keymap.set("v", "<leader>y", "\"+y")        -- Yank to system clipboard (visual mode)
vim.keymap.set("n", "<leader>Y", "\"+Y")        -- Yank entire line to system clipboard

-- Tmux integration
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww goto<CR>")  -- Open tmux window and run `goto`

