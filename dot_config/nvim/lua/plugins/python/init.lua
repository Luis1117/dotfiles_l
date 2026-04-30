-- lua/plugins/python/init.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Ponto de entrada da pasta python/.
-- O lazy.nvim lê este init.lua e carrega os demais automaticamente.
-- REGRA: este arquivo só pode retornar uma tabela de specs válidas.
-- O setup() do core.python é chamado dentro do config() abaixo.
-- ─────────────────────────────────────────────────────────────────────────────
--
-- -- lua/plugins/python/init.lua
return {
  {
    dir      = vim.fn.stdpath("config"),
    name     = "python-core-setup",
    lazy     = false,
    priority = 1000,
    config   = function()
      require("core.python").setup()
    end,
  },
}
