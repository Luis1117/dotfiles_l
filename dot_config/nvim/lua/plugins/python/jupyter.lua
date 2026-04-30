-- lua/plugins/python/jupyter.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Suporte a Jupyter: Molten (execução inline), image.nvim, Jupytext
-- ─────────────────────────────────────────────────────────────────────────────

local function notify(msg, level, title)
  if package.loaded["snacks"] then
    require("snacks").notify(msg, { title = title or "Jupyter", level = "info" })
  else
    vim.notify(msg, level or vim.log.levels.INFO)
  end
end

return {
  -- ── Molten: execução de células inline ────────────────────────────────────
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
      vim.g.molten_go_to_output_on_run   = false

      -- Auto-salvar após cada execução
      vim.api.nvim_create_autocmd("User", {
        pattern  = "MoltenEvaluateFinished",
        callback = function()
          vim.schedule(function() vim.cmd("MoltenSave") end)
        end,
      })
    end,
    keys = {
      { "<leader>mi", "<cmd>MoltenInit<CR>",           desc = "Molten: Init kernel" },
      { "<leader>mq", "<cmd>MoltenDeinit<CR>",         desc = "Molten: Shutdown" },
      { "<leader>ml", "<cmd>MoltenEvaluateLine<CR>",   desc = "Molten: Run line" },
      { "<leader>mr", "<cmd>MoltenReevaluateCell<CR>", desc = "Molten: Re-run cell" },
      { "<leader>md", "<cmd>MoltenDelete<CR>",         desc = "Molten: Delete cell" },
      { "<leader>mo", "<cmd>MoltenShowOutput<CR>",     desc = "Molten: Show output" },
      { "<leader>mh", "<cmd>MoltenHideOutput<CR>",     desc = "Molten: Hide output" },
      { "<leader>mj", "<cmd>MoltenSave<CR>",           desc = "Molten: Save JSON" },
      { "<leader>mJ", "<cmd>MoltenLoad<CR>",           desc = "Molten: Load JSON" },

      -- Executar seleção visual mantendo cursor no fim da seleção
      {
        "<leader>mc",
        function()
          -- estas funções funcionam DENTRO do visual mode
          local end_row = vim.fn.line("v")
          local cur_row = vim.fn.line(".")
          local last    = math.max(end_row, cur_row)
          local last_col = vim.fn.col(math.max(end_row, cur_row) == end_row and "v" or ".")
          vim.cmd(":<C-u>MoltenEvaluateVisual")
          vim.api.nvim_win_set_cursor(0, { last, math.max(last_col - 1, 0) })
        end,
        mode = "v",
        desc = "Molten: Run visual",
      },

      -- Copiar output para clipboard
      {
        "<leader>my",
        function()
          vim.cmd("MoltenShowOutput")
          vim.defer_fn(function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].filetype == "molten_output" then
                local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                local text  = table.concat(lines, "\n")
                vim.fn.setreg("+", text)
                vim.fn.setreg('"', text)
                notify("Output copiado (" .. #lines .. " linhas)")
                vim.cmd("MoltenHideOutput")
                return
              end
            end
            notify("Nenhum output encontrado", vim.log.levels.WARN)
          end, 150)
        end,
        desc = "Molten: Copy output",
      },
    },
  },

  -- ── image.nvim: renderizar imagens no terminal ────────────────────────────
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    opts = {
      backend      = "kitty",
      integrations = {
        markdown = { enabled = true },
      },
      max_height_window_percentage = 50,
      max_width_window_percentage  = 50,
    },
  },

  -- ── Jupytext: editar .ipynb como .py ──────────────────────────────────────
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    config = function()
      require("jupytext").setup({
        style            = "percent",
        output_extension = "auto",
        force_ft         = "python",
      })

      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern  = "*.ipynb",
        callback = function()
          vim.bo.filetype = "python"
        end,
      })
    end,
    keys = {
      { "<leader>jn", "<cmd>!jupytext --to notebook %<CR>",   desc = "Jupyter: → .ipynb" },
      { "<leader>jp", "<cmd>!jupytext --to py:percent %<CR>", desc = "Jupyter: → .py" },
      {
        "<leader>jl",
        function()
          vim.fn.jobstart("jupyter lab", { detach = true })
          notify("Jupyter Lab iniciado!")
        end,
        desc = "Jupyter: Start Lab",
      },
    },
  },

  -- ── Which-key: grupos de teclas Python ────────────────────────────────────
  {
    "folke/which-key.nvim",
    optional = true,
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      vim.list_extend(opts.spec, {
        { "<leader>r",  group = "repl/run" },
        { "<leader>s",  group = "send" },
        { "<leader>m",  group = "molten" },
        { "<leader>j",  group = "jupyter" },
        { "<leader>d",  group = "debug/diagnostic" },
        { "<leader>de", desc  = "Diagnostics float" },
        { "<leader>dq", desc  = "Diagnostics loclist" },
        { "<leader>dy", desc  = "Copy diagnostic" },
      })
    end,
  },
}
