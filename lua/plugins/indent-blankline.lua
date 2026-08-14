return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",  -- ibl = new entrypoint since v3
  event = "BufReadPost",
  opts = {
    indent = { char = "│" }, -- character for indentation guide
    scope = { enabled = true }, -- highlight current scope
  },
  config = function(_, opts)
    require("ibl").setup(opts)
    vim.api.nvim_create_autocmd("BufReadPost", {
      desc = "Disable indent guides on large files",
      callback = function(event)
        if vim.b[event.buf].large_file then
          require("ibl").setup_buffer(event.buf, { enabled = false })
        end
      end,
    })
  end,
}
