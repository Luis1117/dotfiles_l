return {
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown", "org", "vimwiki" },
    keys = {
      { "<leader>tm", "<cmd>TableModeToggle<cr>", desc = "Toggle Table Mode" },
      { "<leader>tr", "<cmd>TableModeRealign<cr>", desc = "Realign Table" },
      { "<leader>tt", "<cmd>Tableize<cr>", mode = "v", desc = "CSV to Table" },
      { "<leader>tdd", "<cmd>TableModeDeleteRow<cr>", desc = "Delete Row" },
      { "<leader>tdc", "<cmd>TableModeDeleteColumn<cr>", desc = "Delete Column" },
      { "<leader>tic", "<cmd>TableModeInsertColumn<cr>", desc = "Insert Column" },
    },
    config = function()
      -- Estilo da tabela
      vim.g.table_mode_corner = '|'
      vim.g.table_mode_corner_corner = '|'
      vim.g.table_mode_header_fillchar = '-'
      
      -- Alinhamento
      vim.g.table_mode_align_char = ':'
      vim.g.table_mode_auto_align = 1
      
      -- Delimiter para CSV
      vim.g.table_mode_delimiter = ','
      
      -- Fórmulas (tipo Excel)
      vim.g.table_mode_syntax = 1
      vim.g.table_mode_expr = 1
      
      -- Mensagens visuais
      vim.g.table_mode_verbose = 1
      
      -- Prefix para comandos (padrão: <leader>t)
      vim.g.table_mode_map_prefix = '<Leader>t'
      
      -- ⭐ AUTO-ATIVAR EM MARKDOWN
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "vimwiki" },
        callback = function()
          vim.cmd("TableModeEnable")
        end,
        desc = "Auto-ativar Table Mode em Markdown",
      })
    end,
  },
}
