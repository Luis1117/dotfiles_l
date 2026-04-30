-- ~/.config/nvim/lua/plugins/toggleterm.lua
-- Terminal integrado + Runner Python + REPL + LazyGit

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping  = [[<c-\>]],
      hide_numbers  = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size  = true,
      persist_mode  = true,
      direction     = "float",
      close_on_exit = true,
      shell         = vim.o.shell,
      auto_scroll   = true,
      float_opts    = {
        border     = "curved",
        winblend   = 0,
        highlights = {
          border     = "Normal",
          background = "Normal",
        },
      },
    })

    local Terminal = require("toggleterm.terminal").Terminal

    -- ═══════════════════════════════════════════════════════════════════════
    -- RUNNER PYTHON
    -- Roda arquivo .py ou seleção visual usando o venv detectado pelo core.python
    -- ═══════════════════════════════════════════════════════════════════════

    -- <leader>rp — roda o arquivo .py atual
    vim.keymap.set("n", "<leader>rp", function()
      local py     = require("core.python")
      local python = py.python_path or "python3"
      local file   = vim.fn.expand("%:p")

      if file == "" or not file:match("%.py$") then
        vim.notify("Nenhum arquivo Python aberto", vim.log.levels.WARN)
        return
      end

      vim.cmd("write")

      Terminal:new({
        cmd           = string.format('%s "%s"', python, file),
        direction     = "horizontal",
        close_on_exit = false,
        on_open       = function(t)
          vim.cmd("startinsert!")
          vim.keymap.set("n", "q", function() t:close() end,
            { buffer = t.bufnr, silent = true })
        end,
      }):toggle()
    end, { desc = "Python: Run file" })

    -- <leader>rP — roda seleção visual em arquivo temporário
    vim.keymap.set("v", "<leader>rP", function()
      local py     = require("core.python")
      local python = py.python_path or "python3"

      local start_line = vim.fn.line("'<")
      local end_line   = vim.fn.line("'>")
      local lines      = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      local tmpfile    = vim.fn.tempname() .. ".py"
      vim.fn.writefile(lines, tmpfile)

      Terminal:new({
        cmd           = string.format('%s "%s"', python, tmpfile),
        direction     = "horizontal",
        close_on_exit = false,
        on_open       = function(t)
          vim.cmd("startinsert!")
          vim.keymap.set("n", "q", function()
            vim.fn.delete(tmpfile)
            t:close()
          end, { buffer = t.bufnr, silent = true })
        end,
      }):toggle()
    end, { desc = "Python: Run selection" })

    -- ═══════════════════════════════════════════════════════════════════════
    -- REPL PYTHON (IPYTHON)
    -- ═══════════════════════════════════════════════════════════════════════
    local python_repl = Terminal:new({
      cmd           = "poetry run ipython",
      direction     = "vertical",
      close_on_exit = false,
      hidden        = false,
      on_open       = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(
          term.bufnr, "n", "q", "<cmd>close<CR>",
          { noremap = true, silent = true }
        )
      end,
    })

    function _PYTHON_REPL_TOGGLE()
      python_repl:toggle()
    end

    local function send_to_repl(text)
      if not python_repl:is_open() then
        python_repl:open()
      end
      python_repl:send(text, false)
    end

    vim.keymap.set("n", "<leader>pt", _PYTHON_REPL_TOGGLE,
      { desc = "Toggle Python REPL" })

    vim.keymap.set("n", "<leader>pl", function()
      local line = vim.api.nvim_get_current_line()
      send_to_repl(line)
    end, { desc = "Send line to REPL" })

    vim.keymap.set("v", "<leader>ps", function()
      local start_line = vim.fn.getpos("'<")[2]
      local end_line   = vim.fn.getpos("'>")[2]
      local lines      = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      send_to_repl(table.concat(lines, "\n"))
    end, { desc = "Send selection to REPL" })

    vim.keymap.set("n", "<leader>pc", function()
      local current_line = vim.fn.line(".")
      local start_line   = current_line
      local total_lines  = vim.fn.line("$")

      while start_line > 1 do
        if vim.fn.getline(start_line):match("^# %%%%") then break end
        start_line = start_line - 1
      end

      local end_line = current_line + 1
      while end_line <= total_lines do
        if vim.fn.getline(end_line):match("^# %%%%") then
          end_line = end_line - 1
          break
        end
        end_line = end_line + 1
      end

      if end_line > total_lines then end_line = total_lines end

      local cell_start = start_line
      if vim.fn.getline(start_line):match("^# %%%%") then
        cell_start = start_line + 1
      end

      local lines = vim.fn.getline(cell_start, end_line)
      send_to_repl(table.concat(lines, "\n"))
    end, { desc = "Send cell to REPL" })

    vim.keymap.set("n", "<leader>pC", function()
      send_to_repl("clear")
    end, { desc = "Clear REPL" })

    vim.keymap.set("n", "<leader>pf", function()
      if python_repl:is_open() then
        vim.cmd("wincmd p")
      else
        python_repl:open()
      end
    end, { desc = "Focus REPL" })

    -- ═══════════════════════════════════════════════════════════════════════
    -- LAZYGIT
    -- ═══════════════════════════════════════════════════════════════════════
    local lazygit = Terminal:new({
      cmd        = "lazygit",
      dir        = "git_dir",
      direction  = "float",
      float_opts = { border = "double" },
      on_open    = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(
          term.bufnr, "n", "q", "<cmd>close<CR>",
          { noremap = true, silent = true }
        )
      end,
    })

    function _LAZYGIT_TOGGLE()
      lazygit:toggle()
    end

    vim.keymap.set("n", "<leader>gg", _LAZYGIT_TOGGLE,
      { desc = "Toggle LazyGit" })

    -- ═══════════════════════════════════════════════════════════════════════
    -- TERMINAIS DIRECIONAIS
    -- ═══════════════════════════════════════════════════════════════════════
    vim.keymap.set("n", "<leader>th", function()
      vim.cmd("ToggleTerm size=15 direction=horizontal")
    end, { desc = "Toggle horizontal terminal" })

    vim.keymap.set("n", "<leader>tv", function()
      vim.cmd("ToggleTerm size=" .. math.floor(vim.o.columns * 0.4) .. " direction=vertical")
    end, { desc = "Toggle vertical terminal" })

    vim.keymap.set("n", "<leader>tf", function()
      vim.cmd("ToggleTerm direction=float")
    end, { desc = "Toggle float terminal" })
  end,
}
