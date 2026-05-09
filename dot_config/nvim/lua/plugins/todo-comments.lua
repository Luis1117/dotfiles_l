return {
  "folke/todo-comments.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  event = "VeryLazy",
  keys = {
    {
      "]t",
      function()
        require("todo-comments").jump_next()
      end,
      desc = "Next TODO",
    },
    {
      "[t",
      function()
        require("todo-comments").jump_prev()
      end,
      desc = "Previous TODO",
    },
    {
      "<leader>ft",
      "<cmd>TodoTelescope keywords=TODO,FIX,HACK,WARN,PERF,NOTE,QWIP<cr>",
      desc = "Search TODOs",
    },
    {
      "<leader>fT",
      "<cmd>TodoQuickFix keywords=TODO,FIX,HACK,WARN,PERF,NOTE,QWIP<cr>",
      desc = "TODOs quickfix",
    },
    {
      "<leader>tl",
      "<cmd>TodoLocList keywords=TODO,FIX,HACK,WARN,PERF,NOTE,QWIP<cr>",
      desc = "TODOs in loclist",
    },
  },
  config = function()
    require("todo-comments").setup({
      signs = true,
      keywords = {
        FIX = {
          icon  = " ",
          color = "error",
          alt   = { "FIXME", "BUG", "FIXIT", "ISSUE" },
        },
        TODO = {
          icon  = " ",
          color = "info",
        },
        HACK = {
          icon  = " ",
          color = "warning",
        },
        WARN = {
          icon  = " ",
          color = "warning",
          alt   = { "WARNING", "XXX" },
        },
        PERF = {
          icon = " ",
          alt  = { "OPTIM", "PERFORMANCE", "OPTIMIZE" },
        },
        NOTE = {
          icon  = " ",
          color = "hint",
          alt   = { "INFO" },
        },
        QWIP = {
          icon  = "Q",
          color = "hint",
        },
      },
      highlight = {
        multiline         = true,
        multiline_pattern = "^.",
        multiline_context = 10,
        before            = "",
        keyword           = "bg",
        after             = "fg",
        pattern           = [[.*<(KEYWORDS)\s*:]],
        comments_only     = true,
        max_line_len      = 400,
        exclude           = {},
      },
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
        },
        pattern = [[\b(KEYWORDS)\b\s*:]],
      },
    })
  end,
}
