-- lua/plugins/c-dev.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- C/C++: clangd (vim.lsp.config) + DAP/GDB + conform + cmake
-- Keymaps globais de LSP estão em plugins/lsp.lua
-- ─────────────────────────────────────────────────────────────────────────────

return {
  -- ── Instala clangd via Mason ───────────────────────────────────────────────
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "clangd", "codelldb" })
    end,
  },

  -- ── clangd via vim.lsp.config ─────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
        init_options = {
          usePlaceholders    = true,
          completeUnimported = true,
          clangdFileStatus   = true,
        },
        filetypes    = { "c", "cpp", "objc", "objcpp" },
        root_markers = { "compile_commands.json", "compile_flags.txt", "Makefile", ".git" },
      })
      vim.lsp.enable("clangd")
    end,
  },

  -- ── Treesitter ────────────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "c", "cpp", "make", "cmake", "asm" })
    end,
  },

  -- ── DAP GDB ───────────────────────────────────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    ft           = { "c", "cpp" },
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")

      dap.adapters.gdb = {
        type    = "executable",
        command = "gdb",
        args    = { "-i", "dap" },
      }

      dap.configurations.c = {
        {
          name    = "Launch",
          type    = "gdb",
          request = "launch",
          program = function()
            return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd                             = "${workspaceFolder}",
          stopAtBeginningOfMainSubprogram = false,
        },
        {
          name      = "Attach to process",
          type      = "gdb",
          request   = "attach",
          processId = require("dap.utils").pick_process,
          cwd       = "${workspaceFolder}",
        },
      }
      dap.configurations.cpp = dap.configurations.c

      require("nvim-dap-virtual-text").setup({
        enabled                     = true,
        highlight_changed_variables = true,
        show_stop_reason            = true,
        commented                   = false,
      })

      vim.fn.sign_define("DapBreakpoint",          { text = "🔴", texthl = "DapBreakpoint" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DapBreakpointCondition" })
      vim.fn.sign_define("DapStopped",             { text = "▶️",  texthl = "DapStopped", linehl = "debugPC" })
    end,
    keys = {
      { "<F5>",       function() require("dap").continue() end,                                  desc = "Debug: Continue" },
      { "<F10>",      function() require("dap").step_over() end,                                 desc = "Debug: Step Over" },
      { "<F11>",      function() require("dap").step_into() end,                                 desc = "Debug: Step Into" },
      { "<F12>",      function() require("dap").step_out() end,                                  desc = "Debug: Step Out" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional Breakpoint" },
      { "<leader>dr", function() require("dap").repl.open() end,                                 desc = "Open REPL" },
    },
  },

  -- ── Conform clang-format ──────────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        c   = { "clang_format" },
        cpp = { "clang_format" },
      },
    },
  },

  -- ── CMake Tools ───────────────────────────────────────────────────────────
  {
    "Civitasv/cmake-tools.nvim",
    ft           = { "c", "cpp", "cmake" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>cg", "<cmd>CMakeGenerate<cr>",        desc = "CMake Generate" },
      { "<leader>cb", "<cmd>CMakeBuild<cr>",           desc = "CMake Build" },
      { "<leader>cR", "<cmd>CMakeRun<cr>",             desc = "CMake Run" },
      { "<leader>cD", "<cmd>CMakeDebug<cr>",           desc = "CMake Debug" },
      { "<leader>cs", "<cmd>CMakeSelectBuildType<cr>", desc = "CMake Select Build Type" },
    },
    opts = {},
  },
}
