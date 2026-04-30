-- ~/.config/nvim/lua/plugins/postgresql.lua
-- CONFIGURAÇÃO COMPLETA PARA POSTGRESQL

return {
  -- ============================================================================
  -- 1. SQLS - LSP para SQL/PostgreSQL
  -- ============================================================================
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "sqls",           -- SQL Language Server
        "sqlfluff",       -- Linter
        "sql-formatter",  -- Formatter
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sqls = {
          settings = {
            sqls = {
              connections = {
                {
                  driver = "postgresql",
                  dataSourceName = "host=127.0.0.1 port=5432 user=postgres password=postgres dbname=postgres sslmode=disable",
                },
              },
            },
          },
        },
      },
    },
  },

  -- ============================================================================
  -- 2. VIM-DADBOD - Executar queries SQL
  -- ============================================================================
  {
    "tpope/vim-dadbod",
    cmd = "DB",
  },

  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
    keys = {
      { "<leader>db", "<cmd>DBUIToggle<CR>", desc = "Database: Toggle UI" },
      { "<leader>df", "<cmd>DBUIFindBuffer<CR>", desc = "Database: Find buffer" },
      { "<leader>dr", "<cmd>DBUIRenameBuffer<CR>", desc = "Database: Rename buffer" },
      { "<leader>dq", "<cmd>DBUILastQueryInfo<CR>", desc = "Database: Last query info" },
    },
    init = function()
      -- Configurações do vim-dadbod-ui
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 40

      -- Salvar conexões no arquivo
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/dadbod_ui"

      -- Auto-executar query ao salvar
      vim.g.db_ui_execute_on_save = 0

      -- Ícones customizados
      vim.g.db_ui_icons = {
        expanded = {
          db = "▾ ",
          buffers = "▾ ",
          saved_queries = "▾ ",
          schemas = "▾ ",
          schema = "▾ פּ",
          tables = "▾ 藺",
          table = "▾ ",
        },
        collapsed = {
          db = "▸ ",
          buffers = "▸ ",
          saved_queries = "▸ ",
          schemas = "▸ ",
          schema = "▸ פּ",
          tables = "▸ 藺",
          table = "▸ ",
        },
        saved_query = "",
        new_query = "璘",
        tables = "離",
        buffers = "﬘",
        add_connection = "",
        connection_ok = "✓",
        connection_error = "✕",
      }
    end,
    config = function()
      -- Autocommand para arquivos SQL
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          -- Configurações específicas para SQL
          vim.opt_local.commentstring = "-- %s"
          vim.opt_local.expandtab = true
          vim.opt_local.shiftwidth = 2
          vim.opt_local.tabstop = 2
          vim.opt_local.softtabstop = 2

          -- Keybindings específicos para SQL
          local opts = { buffer = true, noremap = true, silent = true }

          -- Executar query sob o cursor (com vim-dadbod)
          vim.keymap.set("n", "<leader>se", "<Plug>(DBUI_ExecuteQuery)", opts)
          vim.keymap.set("v", "<leader>se", "<Plug>(DBUI_ExecuteQuery)", opts)

          -- Salvar query
          vim.keymap.set("n", "<leader>ss", "<Plug>(DBUI_SaveQuery)", opts)

          -- Formatar query
          vim.keymap.set("n", "<leader>sf", function()
            vim.lsp.buf.format()
          end, opts)
        end,
      })

      -- Comando para conectar rapidamente ao PostgreSQL local
      vim.api.nvim_create_user_command("PGConnect", function(opts)
        local dbname = opts.args ~= "" and opts.args or "postgres"
        local conn = string.format(
          "postgresql://postgres:postgres@localhost:5432/%s",
          dbname
        )
        vim.g.db = conn
        vim.notify("✓ Conectado ao banco: " .. dbname, vim.log.levels.INFO)
      end, {
        nargs = "?",
        desc = "Conectar ao PostgreSQL local",
      })

      -- Comando para listar tabelas
      vim.api.nvim_create_user_command("PGTables", function()
        if not vim.g.db then
          vim.notify("❌ Nenhuma conexão ativa. Use :PGConnect", vim.log.levels.ERROR)
          return
        end
        
        local query = "SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name;"
        vim.cmd("DB " .. query)
      end, {
        desc = "Listar tabelas do PostgreSQL",
      })
    end,
  },

  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "tpope/vim-dadbod", "hrsh7th/nvim-cmp" },
    ft = { "sql", "mysql", "plsql" },
    config = function()
      -- Adicionar dadbod-completion ao nvim-cmp
      require("cmp").setup.filetype({ "sql", "mysql", "plsql" }, {
        sources = {
          { name = "vim-dadbod-completion" },
          { name = "buffer" },
        },
      })
    end,
  },

  -- ============================================================================
  -- 3. CONFORM - Formatação SQL
  -- ============================================================================
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.sql = { "sql_formatter" }
      opts.formatters_by_ft.mysql = { "sql_formatter" }
      opts.formatters_by_ft.plsql = { "sql_formatter" }

      -- Configurações do sql-formatter
      opts.formatters = opts.formatters or {}
      opts.formatters.sql_formatter = {
        prepend_args = {
          "-l", "postgresql",  -- Dialect: postgresql, mysql, mariadb, etc.
          "-i", "2",           -- Indent com 2 espaços
          "-u",                -- Uppercase keywords
        },
      }
    end,
  },

  -- ============================================================================
  -- 4. NVIM-LINT - Linting SQL
  -- ============================================================================
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.sql = { "sqlfluff" }
    end,
  },

  -- ============================================================================
  -- 5. SYNTAX HIGHLIGHTING
  -- ============================================================================
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "sql" })
    end,
  },

  -- ============================================================================
  -- 6. WHICH-KEY
  -- ============================================================================
  {
    "folke/which-key.nvim",
    optional = true,
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      vim.list_extend(opts.spec, {
        { "<leader>d", group = "database" },
        { "<leader>s", group = "sql" },
      })
    end,
  },
}
