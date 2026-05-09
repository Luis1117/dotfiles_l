-- ~/.config/nvim/lua/plugins/ui.lua

return {
  -- ── Mini Icons ────────────────────────────────────────────────────
  {
    "echasnovski/mini.icons",
    version = false,
    config = function()
      require("mini.icons").setup()
    end,
  },
}
