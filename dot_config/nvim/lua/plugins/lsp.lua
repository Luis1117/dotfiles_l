-- lua/plugins/lsp.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- LSP global: Mason base + keymaps LspAttach + diagnósticos
-- Cada linguagem configura seu servidor no seu próprio arquivo
-- ─────────────────────────────────────────────────────────────────────────────

return {
  -- ── Mason base ────────────────────────────────────────────────────────────
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    lazy  = false,
    opts  = {},
  },

  -- ── Keymaps globais + diagnósticos ────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      -- Diagnósticos
      vim.diagnostic.config({
        virtual_text     = { prefix = "●" },
        signs            = true,
        underline        = true,
        update_in_insert = false,
        severity_sort    = true,
        float = {
          border = "rounded",
          source = true,
        },
      })

      -- Keymaps ao anexar LSP a qualquer buffer/linguagem
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local buf  = ev.buf
          local opts = { buffer = buf, noremap = true, silent = true }

          vim.keymap.set("n", "gd",         vim.lsp.buf.definition,      opts)
          vim.keymap.set("n", "gD",         vim.lsp.buf.declaration,     opts)
          vim.keymap.set("n", "gi",         vim.lsp.buf.implementation,  opts)
          vim.keymap.set("n", "gr",         vim.lsp.buf.references,      opts)
          vim.keymap.set("n", "gy",         vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "K",          vim.lsp.buf.hover,           opts)
          vim.keymap.set("n", "<leader>k",  vim.lsp.buf.signature_help,  opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,          opts)
          -- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,     opts)
          vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,    opts)
          vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,    opts)
          vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float,   opts)
          vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist,   opts)
          vim.keymap.set("n", "<leader>dy", "<cmd>DiagnosticCopy<CR>",   opts)
        end,
      })
    end,
  },
}
