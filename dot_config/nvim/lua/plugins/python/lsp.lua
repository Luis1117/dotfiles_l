-- lua/plugins/python/lsp.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- LSP Python: pyright + ruff (vim.lsp.config nativo)
-- DAP + DAP UI + Conform + lint + image.nvim + Molten
-- Keymaps globais de LSP estão em plugins/lsp.lua
-- ─────────────────────────────────────────────────────────────────────────────

return {
  -- ── Instala pyright, ruff, debugpy via Mason ──────────────────────────────
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "pyright", "ruff", "debugpy" })
    end,
  },

  -- ── Pyright + Ruff via vim.lsp.config ─────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      vim.lsp.config("pyright", {
        filetypes    = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", ".git" },
        settings = {
          python = {
            analysis = {
              autoSearchPaths        = true,
              useLibraryCodeForTypes = true,
              diagnosticMode         = "workspace",
              typeCheckingMode       = "basic",
            },
          },
        },
        on_init = function(client)
          local py   = require("core.python")
          local path = py.python_path
          if path and vim.fn.executable(path) == 1 then
            client.config.settings.python.pythonPath = path
            client.notify("workspace/didChangeConfiguration", { settings = nil })
          end
        end,
      })
      vim.lsp.enable("pyright")

      vim.lsp.config("ruff", {
        filetypes    = { "python" },
        root_markers = { "pyproject.toml", "ruff.toml", ".git" },
        on_attach    = function(client, _)
          client.server_capabilities.hoverProvider = false
        end,
      })
      vim.lsp.enable("ruff")
    end,
  },

  -- ── DAP Python ────────────────────────────────────────────────────────────
  {
    "mfussenegger/nvim-dap-python",
    ft           = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local py = require("core.python")
      if py.python_path then
        require("dap-python").setup(py.python_path)
        require("dap-python").test_runner = "pytest"
      end
    end,
    keys = {
      { "<leader>db", "<cmd>DapToggleBreakpoint<CR>",                     desc = "DAP: Toggle breakpoint" },
      { "<leader>dc", "<cmd>DapContinue<CR>",                             desc = "DAP: Continue" },
      { "<leader>ds", "<cmd>DapStepOver<CR>",                             desc = "DAP: Step over" },
      { "<leader>di", "<cmd>DapStepInto<CR>",                             desc = "DAP: Step into" },
      { "<leader>do", "<cmd>DapStepOut<CR>",                              desc = "DAP: Step out" },
      { "<leader>dT", "<cmd>DapTerminate<CR>",                            desc = "DAP: Terminate" },
      { "<leader>dt", function() require("dap-python").test_method() end, desc = "DAP: Test method" },
      { "<leader>dC", function() require("dap-python").test_class() end,  desc = "DAP: Test class" },
    },
  },

  -- ── DAP UI ────────────────────────────────────────────────────────────────
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap   = require("dap")
      local dapui = require("dapui")

      dapui.setup({
        icons = { expanded = "", collapsed = "", current_frame = "" },
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.40 },
              { id = "breakpoints", size = 0.20 },
              { id = "stacks",      size = 0.20 },
              { id = "watches",     size = 0.20 },
            },
            size     = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl",    size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size     = 12,
            position = "bottom",
          },
        },
      })

      dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end
    end,
    keys = {
      { "<leader>du", function() require("dapui").toggle() end,                    desc = "DAP: Toggle UI" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "DAP: Eval expression" },
    },
  },

  -- ── Conform ───────────────────────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format", "ruff_fix" },
      },
      format_on_save = function(bufnr)
        if vim.api.nvim_buf_get_name(bufnr):match("%.ipynb$") then return end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
    },
  },

  -- ── nvim-lint ─────────────────────────────────────────────────────────────
  {
    "mfussenegger/nvim-lint",
    event  = { "BufReadPost", "BufWritePost" },
    opts   = { linters_by_ft = { python = { "ruff" } } },
    config = function(_, opts)
      require("lint").linters_by_ft = opts.linters_by_ft
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        callback = function() require("lint").try_lint() end,
      })
    end,
  },

  -- ── image.nvim ────────────────────────────────────────────────────────────
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    opts = {
      backend     = "kitty",
      integrations = { markdown = { enabled = true } },
      max_height_window_percentage = 50,
      max_width_window_percentage  = 50,
    },
  },

  -- ── Molten ────────────────────────────────────────────────────────────────
  {
    "benlubas/molten-nvim",
    version      = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    build        = ":UpdateRemotePlugins",
    lazy         = false,
    init = function()
      vim.g.molten_virt_text_output      = true
      vim.g.molten_output_virt_lines     = true
      vim.g.molten_auto_open_output      = false
      vim.g.molten_image_provider        = "image.nvim"
      vim.g.molten_auto_image_popup      = false
      vim.g.molten_wrap_output           = true
      vim.g.molten_output_win_max_height = 40
      vim.g.molten_save_path             = vim.fn.stdpath("data") .. "/molten"

      vim.api.nvim_create_autocmd("User", {
        pattern  = "MoltenEvaluateFinished",
        callback = function()
          vim.schedule(function() vim.cmd("MoltenSave") end)
        end,
      })
    end,
    keys = {
      { "<leader>mi", "<cmd>MoltenInit<CR>",           desc = "Molten: Init kernel",    ft = "python" },
      { "<leader>mq", "<cmd>MoltenDeinit<CR>",         desc = "Molten: Shutdown",       ft = "python" },
      { "<leader>ml", "<cmd>MoltenEvaluateLine<CR>",   desc = "Molten: Run line",       ft = "python" },
      { "<leader>mr", "<cmd>MoltenReevaluateCell<CR>", desc = "Molten: Re-run cell",    ft = "python" },
      { "<leader>md", "<cmd>MoltenDelete<CR>",         desc = "Molten: Delete cell",    ft = "python" },
      { "<leader>mo", "<cmd>MoltenShowOutput<CR>",     desc = "Molten: Show output",    ft = "python" },
      { "<leader>mh", "<cmd>MoltenHideOutput<CR>",     desc = "Molten: Hide output",    ft = "python" },
      { "<leader>mj", "<cmd>MoltenSave<CR>",           desc = "Molten: Save to JSON",   ft = "python" },
      { "<leader>mJ", "<cmd>MoltenLoad<CR>",           desc = "Molten: Load from JSON", ft = "python" },
      { "<leader>lc", ":<C-u>MoltenEvaluateVisual<CR>", mode = "v", desc = "Molten: Run selection" },
      { "<leader>mc", ":<C-u>MoltenEvaluateVisual<CR>", mode = "v", desc = "Molten: Run selection" },
      {
        "<leader>my",
        function()
          vim.cmd("MoltenShowOutput")
          vim.defer_fn(function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].filetype == "molten_output" then
                local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                vim.fn.setreg("+", table.concat(lines, "\n"))
                vim.fn.setreg('"',  table.concat(lines, "\n"))
                if package.loaded["snacks"] then
                  require("snacks").notify(
                    "Output copiado (" .. #lines .. " linhas)",
                    { title = "Molten", level = "info" }
                  )
                else
                  vim.notify("✓ Output copiado (" .. #lines .. " linhas)", vim.log.levels.INFO)
                end
                vim.cmd("MoltenHideOutput")
                return
              end
            end
            vim.notify("Nenhum output encontrado", vim.log.levels.WARN)
          end, 150)
        end,
        desc = "Molten: Copy output",
        ft   = "python",
      },
    },
  },
}
