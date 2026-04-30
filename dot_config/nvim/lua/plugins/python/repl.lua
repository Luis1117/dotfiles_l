-- lua/plugins/python/repl.lua
return {
  {
    "Vigemus/iron.nvim",
    keys = {
      { "<leader>rs",    "<cmd>IronRepl<CR>",    desc = "Iron: Start REPL" },
      { "<leader>rr",    "<cmd>IronRestart<CR>", desc = "Iron: Restart REPL" },
      { "<leader>rf",    "<cmd>IronFocus<CR>",   desc = "Iron: Focus REPL" },
      { "<leader>rh",    "<cmd>IronHide<CR>",    desc = "Iron: Hide REPL" },
      { "<leader>sl",    mode = "n",             desc = "Iron: Send line" },
      { "<leader>sc",    mode = { "n", "v" },    desc = "Iron: Send selection" },
      { "<leader>sp",    mode = "n",             desc = "Iron: Send paragraph" },
      { "<leader>sf",    mode = "n",             desc = "Iron: Send file" },
      { "<leader>s<CR>", mode = "n",             desc = "Iron: Send <CR>" },
      { "<leader>cl",    mode = "n",             desc = "Iron: Clear REPL" },
      { "<leader>sq",    mode = "n",             desc = "Iron: Exit REPL" },
    },
    config = function()
      local iron = require("iron.core")

      local function get_python_cmd()
        -- Lê em tempo de execução, não no carregamento do plugin
        local py = require("core.python")
        local current_python = py.python_path or "/usr/bin/python3"

        local ipython_path = current_python:gsub("/python$", "/ipython")
        if vim.fn.executable(ipython_path) == 1 then
          return { ipython_path, "--no-autoindent" }
        else
          return { current_python, "-i" }
        end
      end

      iron.setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            python = {
              command = get_python_cmd,  -- função: reavaliada a cada IronRepl
              format  = require("iron.fts.common").bracketed_paste_python,
            },
            sh = { command = { "zsh" } },
          },
          repl_open_cmd = require("iron.view").split.vertical.botright(60),
        },
        keymaps = {
          send_motion    = "<leader>sc",
          visual_send    = "<leader>sc",
          send_line      = "<leader>sl",
          send_paragraph = "<leader>sp",
          send_file      = "<leader>sf",
          cr             = "<leader>s<CR>",
          interrupt      = "<leader>s<space>",
          exit           = "<leader>sq",
          clear          = "<leader>cl",
        },
        highlight        = { italic = true },
        ignore_blank_lines = true,
      })
    end,
  },
}
