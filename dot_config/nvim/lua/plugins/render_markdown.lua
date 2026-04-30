return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    dependencies = { 
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons'
    },
    keys = {
      { '<leader>mR', '<cmd>RenderMarkdown toggle<cr>', desc = 'Toggle Render Markdown' },
    },
    opts = {
      latex = {
        enabled = true,
        converter = 'latex2text',
        highlight = 'RenderMarkdownMath',
      },
    },
  },
}
