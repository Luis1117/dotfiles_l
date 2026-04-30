return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    plugins = {
      spelling = true,
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    wk.add({
      mode = "n",

      -- ================================
      -- Buffers
      -- ================================
      { "<leader>b",   group = "buffer" },
      { "<leader>bo",  desc = "Fechar outros buffers" },
      { "<leader>br",  desc = "Fechar buffers à direita" },
      { "<leader>bl",  desc = "Fechar buffers à esquerda" },
      { "<leader>bp",  desc = "Fixar/desafixar buffer" },
      { "<leader>brl", desc = "Recarregar buffer atual" },

      -- ================================
      -- Code (C/C++, LSP)
      -- ================================
      { "<leader>c",  group = "code/compile" },
      { "<leader>cc", desc = "[C] Compilar" },
      { "<leader>ce", desc = "[C] Compilar & Executar" },
      { "<leader>cr", desc = "[C] Executar compilado" },
      { "<leader>cm", desc = "[C] Make" },
      { "<leader>cM", desc = "[C] Clean & Make" },
      { "<leader>cv", desc = "[C] Valgrind" },
      { "<leader>ca", desc = "[C] Gerar Assembly" },
      { "<leader>cp", desc = "[C] Preprocessar" },

      -- ================================
      -- File/Find (Telescope)
      -- ================================
      { "<leader>f",  group = "file/find" },
      { "<leader>ff", desc = "Find Files (Root)" },
      { "<leader>fg", desc = "Live Grep (Root)" },
      { "<leader>fd", desc = "Find Files (dir atual)" },
      { "<leader>fD", desc = "Live Grep (dir atual)" },
      { "<leader>fb", desc = "Find Buffers" },
      { "<leader>f/", desc = "Grep no buffer atual" },
      { "<leader>f*", desc = "Buscar palavra no buffer" },
      { "<leader>fp", desc = "RGA buscar PDFs/docs" },

      -- ================================
      -- Git
      -- ================================
      { "<leader>g", group = "git" },

      -- ================================
      -- Help
      -- ================================
      { "<leader>h", desc = "Help Tags" },

      -- ================================
      -- LaTeX
      -- ================================
      { "<leader>l",  group = "latex" },
      { "<leader>lc", desc = "Compilar LaTeX" },
      { "<leader>lv", desc = "Abrir PDF" },
      { "<leader>lL", desc = "Ver log VimTeX" },
      { "<leader>ls", desc = "Status VimTeX" },

      -- ================================
      -- Obsidian
      -- ================================
      { "<leader>o",   group = "obsidian" },

      { "<leader>oq",  desc = "Quick Switch" },
      { "<leader>os",  desc = "Buscar notas" },
      { "<leader>ob",  desc = "Backlinks" },
      { "<leader>og",  desc = "Tags" },
      { "<leader>oc",  desc = "Table of Contents" },
      { "<leader>oL",  desc = "Links da nota" },
      { "<leader>oO",  desc = "Abrir no Obsidian app" },
      { "<leader>or",  desc = "Renomear nota" },
      { "<leader>ow",  desc = "Trocar workspace" },
      { "<leader>oT",  desc = "Inserir template" },

      { "<leader>on",  group = "obsidian/nova nota" },
      { "<leader>on",  desc = "Nova nota" },
      { "<leader>onf", desc = "Nota de template" },
      { "<leader>ont", desc = "Nota de hoje" },
      { "<leader>ony", desc = "Nota de ontem" },
      { "<leader>onm", desc = "Nota de amanhã" },

      { "<leader>oi",  group = "obsidian/imagem" },
      { "<leader>oip", desc = "Colar imagem" },
      { "<leader>oio", desc = "Abrir imagem" },
      { "<leader>oiy", desc = "Copiar path da imagem" },

      { "<leader>ov",  group = "obsidian/visual" },

      -- ================================
      -- Search/Split
      -- ================================
      { "<leader>s",  group = "search/split" },
      { "<leader>sb", desc = "Toggle scrollbind" },

      -- ================================
      -- Terminal
      -- ================================
      { "<leader>t",  group = "terminal" },
      { "<leader>tt", desc = "Toggle Terminal" },
      { "<leader>tf", desc = "Float Terminal" },
      { "<leader>th", desc = "Horizontal Terminal" },
      { "<leader>tv", desc = "Vertical Terminal" },

      -- ================================
      -- Tabela/Markdown
      -- ================================
      { "<leader>T",  group = "tabela/markdown" },
      { "<leader>Tm", desc = "Table Mode" },
      { "<leader>Tf", desc = "Format Table" },
      { "<leader>Tc", desc = "Convert to Table" },

      -- ================================
      -- Misc
      -- ================================
      { "<leader>x",  desc = "Fechar buffer" },
      { "<leader>X",  desc = "Fechar todos exceto atual" },
      { "<leader>e",  desc = "Encontrar arquivos" },
      { "<leader>E",  desc = "Buscar texto" },
      { "<leader>r",  desc = "Arquivos recentes" },
      { "<leader>-",  desc = "Oil: Float" },
      { "<leader>ch", desc = "Toggle Checkbox (Obsidian)" },

      -- ================================
      -- Navegação
      -- ================================
      { "[",  group = "prev" },
      { "]",  group = "next" },
      { "[o", desc = "Link anterior (Obsidian)" },
      { "]o", desc = "Próximo link (Obsidian)" },
      { "g",  group = "goto" },
      { "gs", group = "surround" },

      -- ================================
      -- Visual mode
      -- ================================
      { "<leader>ov",  group = "obsidian/visual", mode = "v" },
      { "<leader>ovx", desc = "Extrair para nova nota",  mode = "v" },
      { "<leader>ovl", desc = "Linkar seleção",          mode = "v" },
      { "<leader>ovn", desc = "Linkar para nova nota",   mode = "v" },
      
      -- ================================
      -- Papis
      -- ================================
      { "<leader>z",  group = "Papis" },
      { "<leader>zs", desc = "Papis: search" },
      { "<leader>zo", desc = "Papis: open file" },
      { "<leader>zn", desc = "Papis: open note" },
    })
  end,
}
