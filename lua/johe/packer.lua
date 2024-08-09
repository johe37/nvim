-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]


-- NVIM PACKER HANDLER
return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- TELESCOPE
  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.8',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- COLORSCHEME
  use { "rose-pine/neovim", as = "rose-pine" }

  -- TREESITTER
  use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})

  -- HARPOON
  use('theprimeagen/harpoon')
end)
