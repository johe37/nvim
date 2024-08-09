function ColorMyPencils(color)
	color = color or "rose-pine"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" }) -- sätter fönstret att vara transparant
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" }) -- sätter flytande fönstret att vara transparant
end

ColorMyPencils()
