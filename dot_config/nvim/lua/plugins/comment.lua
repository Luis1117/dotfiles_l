return {
  'numToStr/Comment.nvim',
  event = 'VeryLazy',
  config = function()
    require('Comment').setup({
      -- Adiciona espaço após o comentário
      padding = true,
      
      -- Mantém cursor na posição ao comentar
      sticky = true,
      
      -- Ignora linhas vazias
      ignore = '^$',
      
      -- Atalhos no modo normal
      toggler = {
        line = 'gcc',  -- Comenta/descomenta linha atual
        block = 'gbc', -- Comenta em bloco (menos usado)
      },
      
      -- Atalhos com operadores (motion)
      opleader = {
        line = 'gc',   -- Ex: gcap (comenta parágrafo)
        block = 'gb',  -- Comentário em bloco
      },
      
      -- Atalhos extras (opcional)
      extra = {
        above = 'gcO', -- Adiciona comentário na linha acima
        below = 'gco', -- Adiciona comentário na linha abaixo
        eol = 'gcA',   -- Adiciona comentário no fim da linha
      },
      
      -- Habilita mapeamentos
      mappings = {
        basic = true,
        extra = true,
      },
    })
  end
}
