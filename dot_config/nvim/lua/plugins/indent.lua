-- nvim/lua/plugins/indent.lua
-- (você já tem esse arquivo — substitua o conteúdo)
return {
  "lukas-reineke/indent-blankline.nvim",
  main    = "ibl",
  event   = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local hooks = require("ibl.hooks")

    -- Paleta de cores por nível de indentação
    local highlight = {
      "RainbowRed",
      "RainbowYellow",
      "RainbowBlue",
      "RainbowOrange",
      "RainbowGreen",
      "RainbowViolet",
      "RainbowCyan",
    }

    -- Define as cores (adapte os hex ao seu tema)
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "RainbowRed",    { fg = "#E06C75" })
      vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
      vim.api.nvim_set_hl(0, "RainbowBlue",   { fg = "#61AFEF" })
      vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
      vim.api.nvim_set_hl(0, "RainbowGreen",  { fg = "#98C379" })
      vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
      vim.api.nvim_set_hl(0, "RainbowCyan",   { fg = "#56B6C2" })
    end)

    -- Integração com treesitter pra highlight do escopo atual
    hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

    require("ibl").setup({
      indent = {
        char      = "│",   -- caractere da guia
        tab_char  = "│",
        highlight = highlight,
      },
      scope = {
        enabled   = true,
        highlight = highlight,
        -- mostra underline no início e fim do escopo atual
        show_start = true,
        show_end   = true,
      },
      exclude = {
        filetypes = {
          "help",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
          "TelescopePrompt",
        },
        buftypes = {
          "terminal",
          "nofile",
        },
      },
    })
  end,
}
