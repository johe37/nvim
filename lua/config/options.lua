-- Set leader key
vim.g.mapleader = " "  -- Use space as leader key

-- Make Mason-installed binaries discoverable to plugins that shell out,
-- without polluting the user's shell PATH. ~/.cargo/bin comes first so a
-- cargo-built `tree-sitter` (built against the host glibc) is preferred
-- over Mason's prebuilt one (which targets newer glibcs than RHEL 9 has).
vim.env.PATH = vim.fn.expand("~/.cargo/bin")
  .. ":" .. vim.fn.stdpath("data") .. "/mason/bin"
  .. ":" .. vim.env.PATH

-- UI Settings
vim.opt.guicursor = ""         -- Use block (fat) cursor
vim.opt.nu = true              -- Show line numbers
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
