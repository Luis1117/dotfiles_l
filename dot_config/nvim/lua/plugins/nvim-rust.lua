-- lua/plugins/nvim-rust.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Rust: rustaceanvim + crates.nvim + rust.vim
-- Keymaps globais de LSP estão em plugins/lsp.lua
-- K é sobrescrito localmente pelo rustaceanvim (hover actions)
-- ─────────────────────────────────────────────────────────────────────────────

return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy    = false,
    ft      = { "rust" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(_, bufnr)
            -- Keymaps específicos do Rust (além dos globais do lsp.lua)
            local map = function(key, cmd, desc)
              vim.keymap.set("n", key, cmd, { buffer = bufnr, desc = desc })
            end

            map("<leader>rr", function() vim.cmd.RustLsp("runnables") end,           "Rust Runnables")
            map("<leader>rd", function() vim.cmd.RustLsp("debuggables") end,         "Rust Debuggables")
            map("<leader>re", function() vim.cmd.RustLsp("expandMacro") end,         "Expand Macro")
            map("<leader>rc", function() vim.cmd.RustLsp("openCargo") end,           "Open Cargo.toml")
            map("<leader>rp", function() vim.cmd.RustLsp("parentModule") end,        "Parent Module")
            map("<leader>rg", function() vim.cmd.RustLsp("crateGraph") end,          "View Crate Graph")
            map("<leader>rm", function() vim.cmd.RustLsp("rebuildProcMacros") end,   "Rebuild Proc Macros")
            map("<leader>rE", function() vim.cmd.RustLsp("explainError") end,        "Explain Error")
            map("<leader>rD", function() vim.cmd.RustLsp("renderDiagnostic") end,    "Render Diagnostic")

            -- Sobrescreve K globalmente com hover actions do Rust
            map("K",          function() vim.cmd.RustLsp({ "hover", "actions" }) end, "Hover Actions")
            map("<leader>rh", function() vim.cmd.RustLsp({ "hover", "actions" }) end, "Hover Actions")
          end,

          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures          = true,
                loadOutDirsFromCheck = true,
                buildScripts         = { enable = true },
              },
              checkOnSave = {
                command   = "clippy",
                extraArgs = { "--all", "--all-features" },
              },
              procMacro = {
                enable  = true,
                ignored = {
                  ["async-trait"]     = { "async_trait" },
                  ["napi-derive"]     = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
              inlayHints = {
                bindingModeHints       = { enable = true },
                closureReturnTypeHints = { enable = "always" },
                parameterHints         = { enable = true },
                typeHints              = { enable = true },
              },
            },
          },
        },

        dap = {
          adapter = require("rustaceanvim.config").get_codelldb_adapter(
            vim.fn.exepath("codelldb"),
            vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/lldb/lib/liblldb.so"
          ),
        },
      }
    end,
  },

  {
    "saecki/crates.nvim",
    event        = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      completion = { cmp = { enabled = true } },
      lsp = {
        enabled    = true,
        actions    = true,
        completion = true,
        hover      = true,
      },
    },
    config = function(_, opts)
      require("crates").setup(opts)

      vim.api.nvim_create_autocmd("BufRead", {
        pattern  = "Cargo.toml",
        callback = function(ev)
          local crates = require("crates")
          local bufnr  = ev.buf
          local map    = function(mode, key, cmd, desc)
            vim.keymap.set(mode, key, cmd, { buffer = bufnr, desc = desc })
          end

          map("n", "<leader>ct", crates.toggle,                  "[Crate] Toggle")
          map("n", "<leader>cr", crates.reload,                  "[Crate] Reload")
          map("n", "<leader>cv", crates.show_versions_popup,     "[Crate] Versions")
          map("n", "<leader>cf", crates.show_features_popup,     "[Crate] Features")
          map("n", "<leader>cd", crates.show_dependencies_popup, "[Crate] Deps")
          map("n", "<leader>cu", crates.update_crate,            "[Crate] Update")
          map("v", "<leader>cu", crates.update_crates,           "[Crate] Update sel.")
          map("n", "<leader>cA", crates.update_all_crates,       "[Crate] Update all")
          map("n", "<leader>cU", crates.upgrade_crate,           "[Crate] Upgrade")
          map("v", "<leader>cU", crates.upgrade_crates,          "[Crate] Upgrade sel.")
        end,
      })
    end,
  },

  {
    "rust-lang/rust.vim",
    ft   = "rust",
    init = function()
      vim.g.rustfmt_autosave      = 1
      vim.g.rustfmt_emit_files    = 1
      vim.g.rustfmt_fail_silently = 0
      vim.g.rust_clip_command     = "wl-copy"
    end,
  },

  {
    "nvim-neotest/neotest",
    optional     = true,
    dependencies = { "rouge8/neotest-rust" },
    opts         = { adapters = { ["neotest-rust"] = {} } },
  },
}
