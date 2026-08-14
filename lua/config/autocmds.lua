-- Match files like `*.js.ejs`, `*.ts.ejs`, `*.json.ejs`, etc.
-- and treat them as if they were the base filetype (`js`, `ts`, `json`, etc.)
vim.filetype.add({
  pattern = {
    ["%.ejs$"] = function(path)
      local base_ext = path:match("(%a+)%.ejs$")
      local map = {
        js = "javascript",
        yml = "yaml",
        yaml = "yaml",
        ts = "typescript",
        json = "json",
        css = "css",
        html = "html",
      }
      return map[base_ext]
    end,
  },
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight on yank",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- Skip treesitter, folds, and syntax on big files (minified JSON, generated code, …)
local large_file_bytes = 512 * 1024
vim.api.nvim_create_autocmd("BufReadPre", {
  desc = "Mark large files so expensive features can skip them",
  group = vim.api.nvim_create_augroup("large-file", { clear = true }),
  callback = function(event)
    local ok, stat = pcall(vim.uv.fs_stat, event.match)
    if not (ok and stat and stat.size > large_file_bytes) then
      return
    end
    vim.b[event.buf].large_file = true
    vim.opt_local.foldenable = false
    vim.opt_local.swapfile = false
    vim.opt_local.undofile = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Enable treesitter highlight unless the buffer is a large file",
  group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
  callback = function(event)
    if vim.b[event.buf].large_file then
      pcall(vim.treesitter.stop, event.buf)
      vim.bo[event.buf].syntax = "off"
      return
    end
    pcall(vim.treesitter.start)
  end,
})

