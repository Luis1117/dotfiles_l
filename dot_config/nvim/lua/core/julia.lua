-- lua/core/julia.lua

-- Configurações básicas para Julia

-- Configura Treesitter para Julia
require("nvim-treesitter.configs").setup({
  ensure_installed = { "julia" },  -- adiciona julia
  highlight = { enable = true },
  indent = { enable = true },
})

-- Configura LSP para julia via lspconfig
local lspconfig = require("lspconfig")

lspconfig.julials.setup({
  settings = {
    julia = {
      format = {
        indent = 2,
        margin = 92,
      },
      lint = {
        run = "onSave",
      },
    },
  },
})

-- Snippets (opcional)
local luasnip = require("luasnip")
luasnip.add_snippets("julia", {
  luasnip.snippet("fun", {
    luasnip.text_node("function "), luasnip.insert_node(1, "name"), luasnip.text_node("("),
    luasnip.insert_node(2), luasnip.text_node({")", "\t"}),
    luasnip.insert_node(0),
    luasnip.text_node({"", "end"})
  }),
})

