vim.keymap.set("n", "<leader>pv", vim.cmd.Ex) 	-- go back to file explorer

vim.keymap.set("x", "<leader>p", "\"_dP")       -- be able to copy and paste over marked text using P

vim.keymap.set("n", "<leader>y", "\"+y") 
vim.keymap.set("v", "<leader>y", "\"+y") 
vim.keymap.set("n", "<leader>Y", "\"+Y") 
vim.keymap.set("n", "<leader>Y", "\"+Y") 

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww goto<CR>")

