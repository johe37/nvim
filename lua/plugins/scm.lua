-- Local plugin: VS Code style source control panel + side-by-side diffs.
-- Source lives in <config>/scm.nvim so it can move to its own repo later.
return {
  {
    "scm.nvim",
    dir = vim.fn.stdpath("config") .. "/scm.nvim",
    cmd = { "Scm", "ScmOpen", "ScmClose", "ScmRefresh", "ScmDiff", "ScmDiffClose", "ScmCommit" },
    keys = {
      { "<leader>gg", "<cmd>Scm<cr>", desc = "Source control panel" },
      { "<leader>gd", "<cmd>ScmDiff<cr>", desc = "Diff current file (side by side)" },
      { "<leader>gD", "<cmd>ScmDiff HEAD<cr>", desc = "Diff current file vs HEAD" },
      { "<leader>gc", "<cmd>ScmCommit<cr>", desc = "Commit staged changes" },
    },
    opts = {
      width = 42,
      position = "left",
    },
    config = function(_, opts)
      require("scm").setup(opts)
    end,
  },
}
