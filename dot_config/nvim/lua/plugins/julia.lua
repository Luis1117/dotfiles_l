-- lua/plugins/julia.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Julia: julials (vim.lsp.config) + Iron REPL + Molten
-- Keymaps globais de LSP estão em plugins/lsp.lua
-- ─────────────────────────────────────────────────────────────────────────────

return {
  -- ── julials via vim.lsp.config ────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local function find_julia_project()
        local dir = vim.fn.getcwd()
        while dir ~= "/" do
          if vim.fn.filereadable(dir .. "/Project.toml") == 1 then return dir end
          dir = vim.fn.fnamemodify(dir, ":h")
        end
        return vim.fn.getcwd()
      end

      local julia = vim.fn.expand("~/.julia/environments/nvim-lspconfig/bin/julia")
      if vim.fn.executable(julia) == 1 then
        vim.lsp.config("julials", {
          cmd = {
            julia,
            "--startup-file=no",
            "--history-file=no",
            "--project=" .. find_julia_project(),
            "-e", [[
              using LanguageServer, SymbolServer;
              depot_path = get(ENV, "JULIA_DEPOT_PATH", "");
              project_path = dirname(something(
                Base.current_project(pwd()),
                Base.load_path_expand(LOAD_PATH[2])
              ));
              server = LanguageServer.LanguageServerInstance(
                stdin, stdout, project_path, depot_path
              );
              server.runlinter = true;
              run(server);
            ]],
          },
          filetypes    = { "julia" },
          root_markers = { "Project.toml", ".git" },
        })
        vim.lsp.enable("julials")
      end
    end,
  },

  -- ── Iron REPL ─────────────────────────────────────────────────────────────
  {
    "Vigemus/iron.nvim",
    ft = { "julia" },
    config = function()
      require("iron.core").setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            julia = {
              command = function()
                local cwd = vim.fn.getcwd()
                if vim.fn.filereadable(cwd .. "/Project.toml") == 1 then
                  return { "julia", "--project=" .. cwd }
                end
                return { "julia" }
              end,
            },
          },
          repl_open_cmd = require("iron.view").split.vertical.botright(60),
        },
        keymaps = {
          send_motion    = "<leader>sc",
          visual_send    = "<leader>sc",
          send_file      = "<leader>sf",
          send_line      = "<leader>sl",
          send_paragraph = "<leader>sp",
          cr             = "<leader>s<CR>",
          interrupt      = "<leader>si",
          exit           = "<leader>sq",
          clear          = "<leader>cl",
        },
        highlight          = { italic = true },
        ignore_blank_lines = true,
      })

      vim.keymap.set("n", "<leader>rs", "<cmd>IronRepl<CR>",    { desc = "Iron: Start REPL" })
      vim.keymap.set("n", "<leader>rr", "<cmd>IronRestart<CR>", { desc = "Iron: Restart REPL" })
      vim.keymap.set("n", "<leader>rf", "<cmd>IronFocus<CR>",   { desc = "Iron: Focus REPL" })
      vim.keymap.set("n", "<leader>rh", "<cmd>IronHide<CR>",    { desc = "Iron: Hide REPL" })
    end,
  },

  -- ── Molten (kernel julia-1.11) ────────────────────────────────────────────
  {
    "benlubas/molten-nvim",
    optional = true,
    ft = { "julia" },
    keys = {
      { "<leader>lc", ":<C-u>MoltenEvaluateVisual<CR>", mode = "v", desc = "Molten: Run selection" },
      { "<leader>ml", "<cmd>MoltenEvaluateLine<CR>",               desc = "Molten: Run line" },
      { "<leader>mr", "<cmd>MoltenReevaluateCell<CR>",             desc = "Molten: Re-run cell" },
      { "<leader>mi", "<cmd>MoltenInit<CR>",                       desc = "Molten: Init kernel" },
      { "<leader>mo", "<cmd>MoltenShowOutput<CR>",                 desc = "Molten: Show output" },
      { "<leader>mh", "<cmd>MoltenHideOutput<CR>",                 desc = "Molten: Hide output" },
    },
  },

  -- ── Treesitter ────────────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "julia" } },
  },
}
