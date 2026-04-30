return {
  'junegunn/vim-easy-align',
  -- Configuração opcional: Mapeamentos globais para 'ga'
  -- O plugin já funciona com 'ga' por padrão, mas você pode
  -- definir um mapeamento diferente ou forçar o carregamento aqui.
  init = function()
    -- Garante que o atalho 'ga' funcione no modo normal e visual
    vim.g.easy_align_default_align_char = '&' -- Não essencial, mas define um default
  end,
}
