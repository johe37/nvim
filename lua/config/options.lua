-- Unused remote-plugin hosts (Neovim probes for these on startup)
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Set leader key
vim.g.mapleader = " "  -- Use space as leader key

-- UI Settings
vim.opt.guicursor = ""         -- Use block (fat) cursor
vim.opt.number = true          -- Show line numbers
vim.opt.relativenumber = false -- Don't mix in a relative-number column
vim.opt.signcolumn = "yes"     -- Reserve one gutter for git/LSP signs
vim.opt.wrap = false           -- Disable line wrapping
vim.opt.termguicolors = true   -- Enable true color support
vim.opt.scrolloff = 8          -- Keep 8 lines of context when scrolling

-- Tab and Indentation
vim.opt.tabstop = 2            -- Number of spaces per tab
vim.opt.softtabstop = 2        -- Number of spaces when pressing Tab
vim.opt.shiftwidth = 2         -- Indentation width
vim.opt.expandtab = true       -- Convert tabs to spaces
vim.opt.smartindent = true     -- Smart indentation

-- Search
vim.o.hlsearch = true         -- Highlight search results
vim.o.incsearch = true        -- Show matches as you type
