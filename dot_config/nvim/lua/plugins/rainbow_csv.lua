return {
  -- Rainbow CSV - Coloriza colunas de CSV/TSV/TXT (única solução necessária)
  {
    'mechatroner/rainbow_csv',
    ft = { 'csv', 'tsv', 'txt', 'csv_semicolon', 'csv_whitespace', 'csv_pipe', 'rfc_csv', 'rfc_semicolon' },
    config = function()
      -- Configurações do Rainbow CSV
      vim.g.rainbow_csv_max_columns = 30
      vim.g.disable_rainbow_csv_loading = 0
      
      -- Keymaps específicos para arquivos CSV/TXT
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'csv', 'tsv', 'txt', 'csv_semicolon', 'csv_whitespace', 'csv_pipe' },
        callback = function()
          local opts = { buffer = true, silent = true }
          
          -- Alinhar colunas
          vim.keymap.set('n', '<leader>ca', ':RainbowAlign<CR>', 
            vim.tbl_extend('force', opts, { desc = '[C]SV [A]lign columns' }))
          
          -- Desalinhar colunas
          vim.keymap.set('n', '<leader>cd', ':RainbowShrink<CR>', 
            vim.tbl_extend('force', opts, { desc = '[C]SV [D]esalign columns' }))
          
          -- Query do CSV (como SQL)
          vim.keymap.set('n', '<leader>cq', ':RainbowQuery<CR>', 
            vim.tbl_extend('force', opts, { desc = '[C]SV [Q]uery' }))
          
          -- Mostrar nomes das colunas
          vim.keymap.set('n', '<leader>ch', ':RainbowName<CR>', 
            vim.tbl_extend('force', opts, { desc = '[C]SV show [H]eaders' }))
        end,
      })
    end,
  },

  -- VisiData - Integração com VisiData para análise avançada
  {
    'hat0uma/prelive.nvim',
    dependencies = { 'rcarriga/nvim-notify' },
    ft = { 'csv', 'tsv', 'json', 'xlsx' },
    config = function()
      -- Verificar se VisiData está instalado
      local function check_visidata()
        local handle = io.popen('which vd 2>/dev/null')
        if handle then
          local result = handle:read('*a')
          handle:close()
          return result ~= ''
        end
        return false
      end
      
      -- Criar comando para abrir arquivo atual no VisiData
      vim.api.nvim_create_user_command('VisiData', function()
        if not check_visidata() then
          vim.notify(
            'VisiData não está instalado. Instale com: pip install visidata',
            vim.log.levels.ERROR
          )
          return
        end
        
        local file = vim.fn.expand('%:p')
        if file == '' then
          vim.notify('Nenhum arquivo aberto', vim.log.levels.WARN)
          return
        end
        
        -- Abrir VisiData em terminal flutuante ou split
        vim.cmd('split | terminal vd ' .. vim.fn.shellescape(file))
      end, { desc = 'Abrir arquivo atual no VisiData' })
      
      -- Keymap para abrir VisiData
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'csv', 'tsv', 'json', 'xlsx' },
        callback = function()
          vim.keymap.set('n', '<leader>cv', ':VisiData<CR>', 
            { buffer = true, silent = true, desc = '[C]SV open [V]isiData' })
        end,
      })
    end,
  },
}
