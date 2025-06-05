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
    },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_config = {
            prompt_position = "top",
          },
          -- sorting_strategy = "ascending",
          -- winblend = 10,
        },
        pickers = {
          find_files = {
            hidden = true,     -- Show dotfiles (like `.gitlab/`)
            no_ignore = false, -- Honor .gitignore
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

