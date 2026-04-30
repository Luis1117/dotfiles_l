-- nvim/lua/plugins/rainbow-delimiters.lua
return {
  "HiPhish/rainbow-delimiters.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local rainbow = require("rainbow-delimiters")

    vim.g.rainbow_delimiters = {
      strategy = {
        -- estratégia global: por documento inteiro
        [""] = rainbow.strategy["global"],
        -- em arquivos muito grandes, usa só o escopo local (mais performático)
        vim = rainbow.strategy["local"],
      },
      query = {
        [""]     = "rainbow-delimiters",
        lua      = "rainbow-blocks",
        latex    = "rainbow-blocks",  -- ótimo pra seus .tex
        python   = "rainbow-blocks",
        rust     = "rainbow-delimiters",
        julia    = "rainbow-delimiters",
      },
      priority = {
        [""] = 110,
        lua  = 210,
      },
      highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
      },
    }
  end,
}
