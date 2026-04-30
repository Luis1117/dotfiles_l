return {
  -- LazyGit - Interface visual para Git
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
      { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit Current File" },
      { "<leader>gl", "<cmd>LazyGitFilter<cr>", desc = "LazyGit Log" },
    },
  },

  -- 

  -- Gitsigns - Indicadores de mudanças e navegação inline
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signcolumn = true,
      numhl = false,
      linehl = false,
      word_diff = false,
      watch_gitdir = {
        follow_files = true,
      },
      attach_to_untracked = true,
      current_line_blame = false, -- Desligado por padrão, use <leader>gB para ativar
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 1000,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      preview_config = {
        border = "rounded",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
    },
    keys = {
      -- Navegação entre hunks (mudanças)
      { "]c", function() 
          if vim.wo.diff then return "]c" end
          vim.schedule(function() require("gitsigns").next_hunk() end)
          return "<Ignore>"
        end, expr = true, desc = "Next Git Hunk" 
      },
      { "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() require("gitsigns").prev_hunk() end)
          return "<Ignore>"
        end, expr = true, desc = "Previous Git Hunk"
      },

      -- Ações com hunks
      { "<leader>hs", "<cmd>Gitsigns stage_hunk<cr>", mode = { "n", "v" }, desc = "Stage Hunk" },
      { "<leader>hr", "<cmd>Gitsigns reset_hunk<cr>", mode = { "n", "v" }, desc = "Reset Hunk" },
      { "<leader>hS", "<cmd>Gitsigns stage_buffer<cr>", desc = "Stage Buffer" },
      { "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = "Undo Stage Hunk" },
      { "<leader>hR", "<cmd>Gitsigns reset_buffer<cr>", desc = "Reset Buffer" },
      { "<leader>hp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview Hunk" },
      { "<leader>hd", "<cmd>Gitsigns diffthis<cr>", desc = "Diff This" },
      
      -- Blame
      { "<leader>gb", "<cmd>Gitsigns blame_line<cr>", desc = "Blame Line" },
      { "<leader>gB", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle Line Blame" },
      
      -- Toggle visualizações
      { "<leader>gtd", "<cmd>Gitsigns toggle_deleted<cr>", desc = "Toggle Deleted" },
      { "<leader>gtw", "<cmd>Gitsigns toggle_word_diff<cr>", desc = "Toggle Word Diff" },
    },
  },

  -- Fugitive - Comandos Git completos (opcional, mas útil)
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Ggrep" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git Status" },
      { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git Commit" },
      { "<leader>gp", "<cmd>Git push<cr>", desc = "Git Push" },
      { "<leader>gP", "<cmd>Git pull<cr>", desc = "Git Pull" },
    },
  },
  -- Adicione no final do seu git.lua, dentro do return { }

  -- Diffview - Histórico e comparação de commits
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewToggleFiles",
    },
    keys = {
      -- Diff do working tree atual
      { "<leader>gd", "<cmd>DiffviewOpen<cr>",                desc = "Diff working tree" },
      -- Histórico do arquivo aberto (o mais útil pra você)
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>",       desc = "Histórico deste arquivo" },
      -- Histórico do repo inteiro
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>",         desc = "Histórico do repositório" },
      -- Fechar qualquer view do diffview
      { "<leader>gq", "<cmd>DiffviewClose<cr>",               desc = "Fechar diffview" },
      -- Comparar com N commits atrás (abre input)
      { "<leader>gD", function()
          local n = vim.fn.input("Comparar com HEAD~")
          if n ~= "" then
            vim.cmd("DiffviewOpen HEAD~" .. n)
          end
        end, desc = "Diff HEAD~N" },
    },
    config = function()
      require("diffview").setup({
        view = {
          default = {
            layout = "diff2_horizontal",
          },
          merge_tool = {
            layout = "diff3_mixed",  -- ótimo pra resolver conflitos
            disable_diagnostics = true,
          },
        },
        file_panel = {
          listing_style = "tree",
          win_config = { width = 35 },
        },
        keymaps = {
          view = {
            { "n", "q",         "<cmd>DiffviewClose<cr>",           { desc = "Fechar" } },
            { "n", "<leader>b", "<cmd>DiffviewToggleFiles<cr>",      { desc = "Toggle file panel" } },
          },
          file_panel = {
            { "n", "q",         "<cmd>DiffviewClose<cr>",           { desc = "Fechar" } },
            { "n", "<cr>",      require("diffview.actions").select_next_entry,  { desc = "Próximo arquivo" } },
          },
          file_history_panel = {
            { "n", "q",         "<cmd>DiffviewClose<cr>",           { desc = "Fechar" } },
            { "n", "!",         require("diffview.actions").options, { desc = "Opções" } },
          },
        },
      })
    end,
  },

  -- Neogit - Interface Magit-style para histórico e controle avançado
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = { "Neogit" },
    keys = {
      { "<leader>gn",  "<cmd>Neogit<cr>",              desc = "Neogit status" },
      { "<leader>gnl", "<cmd>Neogit log<cr>",           desc = "Neogit log" },
      { "<leader>gnc", "<cmd>Neogit commit<cr>",        desc = "Neogit commit" },
      { "<leader>gnb", "<cmd>Neogit branch<cr>",        desc = "Neogit branch" },
    },
    config = function()
      require("neogit").setup({
        integrations = {
          diffview  = true,   -- abre diffs no diffview em vez de split simples
          telescope = true,   -- usa telescope pra branch, commits etc
        },
        graph_style = "unicode",  -- log com │ ╮ ─ bonito
        commit_editor = {
          kind = "vsplit",         -- mensagem de commit em vsplit (seus keymaps funcionam)
          show_staged_diff = true, -- mostra o diff do que vai commitar enquanto escreve
        },
        signs = {
          -- compatível com seus signs do gitsigns
          hunk = { "", "" },
          item = { ">", "v" },
          section = { ">", "v" },
        },
      })
    end,
  },

}
