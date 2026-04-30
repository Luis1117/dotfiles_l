return {
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    event = "VeryLazy",
    config = function()
      require("aerial").setup({

        -- 🔴 IMPORTANTE: desativa TODOS os keymaps globais do Aerial
        keymaps = {},

        -- Atalhos LOCAIS (somente dentro do buffer do Aerial)
        on_attach = function(bufnr)
          -- Navegação segura (sem conflitos com Vim)
          vim.keymap.set("n", "[s", "<cmd>AerialPrev<CR>", {
            buffer = bufnr,
            desc = "Aerial anterior",
          })

          vim.keymap.set("n", "]s", "<cmd>AerialNext<CR>", {
            buffer = bufnr,
            desc = "Aerial próximo",
          })

          vim.keymap.set("n", "q", "<cmd>AerialClose<CR>", {
            buffer = bufnr,
            desc = "Fechar Aerial",
          })
        end,

        -- Layout
        layout = {
          max_width = { 40, 0.2 },
          min_width = 20,
          default_direction = "prefer_right",
          placement = "edge",
        },

        open_automatic = false,

        icons = {},

        highlight_mode = "split_width",
        highlight_closest = true,
        highlight_on_hover = true,

        -- Tipos de símbolos mostrados
        filter_kind = {
          "Class",
          "Function",
          "Method",
          "Module",
          "Constructor",
          "Enum",
          "Interface",
          "Struct",
        },

        -- Backends
        backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },

        treesitter = {
          update_delay = 300,
        },

        lsp = {
          diagnostics_trigger_update = true,
          update_when_errors = true,
          update_delay = 300,
        },

        -- Navegação flutuante (opcional)
        nav = {
          border = "rounded",
          max_height = 0.9,
          max_width = 0.8,
          min_height = { 10, 0.1 },
          min_width = { 0.2, 20 },
          win_opts = {
            cursorline = true,
            winblend = 10,
          },
          autojump = false,
          preview = true,
          keymaps = {
            ["<CR>"] = "actions.jump",
            ["<2-LeftMouse>"] = "actions.jump",
            ["<C-v>"] = "actions.jump_vsplit",
            ["<C-s>"] = "actions.jump_split",
            ["q"] = "actions.close",
            ["o"] = "actions.tree_toggle",
          },
        },

        close_on_select = false,
        update_events = "TextChanged,InsertLeave",

        show_guides = true,
        guides = {
          mid_item = "├─",
          last_item = "└─",
          nested_top = "│ ",
          whitespace = "  ",
        },
      })
    end,
  },
}

