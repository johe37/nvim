return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = vim.fn.executable("make") == 1,
        config = function()
          require("telescope").load_extension("fzf")
        end,
      },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Find Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "Find Help" },
      { "<leader>fd", "<cmd>LiveGrepInDir<cr>", desc = "Live Grep in Directory" },
      { "<leader>fr", "<cmd>Telescope resume<cr>", desc = "Resume Last Picker" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_config = {
            prompt_position = "top",
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",               -- include hidden files
            "--glob", "!.git/",       -- exclude .git/
            "--glob", "!node_modules/",
            "--glob", "!venv/",
            "--glob", "!.venv/",
          },
        },
        pickers = {
          find_files = {
                hidden = true,
                no_ignore = true,
                find_command = {
                  "fd", ".", "--type", "f",
                  "--hidden",
                  "--no-ignore",
                  "--no-ignore-vcs",
                  "--exclude", ".git",
                  "--exclude", "node_modules",
                  "--exclude", "venv",
                  "--exclude", ".venv",
                },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })
      vim.api.nvim_create_user_command("LiveGrepInDir", function()
        vim.ui.input({ prompt = "Grep in directory: ", completion = "dir" }, function(input)
          if input and input ~= "" then
            require("telescope.builtin").live_grep({ cwd = input })
          end
        end)
      end, {})

    end,
  },
}
