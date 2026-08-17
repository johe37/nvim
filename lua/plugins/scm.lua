-- johe37/scm.nvim — VS Code style source control panel + side-by-side diffs.
-- `dev = true` uses ~/repos/personal/scm.nvim when that checkout exists
-- (see config.lazy `dev.path` / `fallback`); otherwise lazy clones the GitHub repo.
return {
  {
    "johe37/scm.nvim",
    version = "*",
    dev = true,
    cmd = {
      "Scm",
      "ScmOpen",
      "ScmClose",
      "ScmRefresh",
      "ScmDiff",
      "ScmDiffClose",
      "ScmCommit",
      "ScmLog",
      "ScmFileLog",
      "ScmShow",
      "ScmBlame",
    },
    keys = {
      { "<leader>gg", "<cmd>Scm<cr>", desc = "Source control panel" },
      { "<leader>gd", "<cmd>ScmDiff<cr>", desc = "Diff current file (side by side)" },
      { "<leader>gD", "<cmd>ScmDiff HEAD<cr>", desc = "Diff current file vs HEAD" },
      { "<leader>gc", "<cmd>ScmCommit<cr>", desc = "Commit staged changes" },
      { "<leader>gl", "<cmd>ScmLog<cr>", desc = "Commit history" },
      { "<leader>gL", "<cmd>ScmFileLog<cr>", desc = "History of current file" },
      { "<leader>gB", "<cmd>ScmBlame<cr>", desc = "Inspect commit behind this line" },
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
