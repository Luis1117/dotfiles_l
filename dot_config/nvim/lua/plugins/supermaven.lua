-- lua/plugins/supermaven.lua
return {
  "supermaven-inc/supermaven-nvim",
  event = "InsertEnter",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion  = "<C-]>",
        accept_word       = "<C-j>",
      },
      ignore_filetypes = {
        "TelescopePrompt",
        "neo-tree",
        "dashboard",
      },
      color = {
        suggestion_color = "#6c7086",
        cterm            = 244,
      },
      log_level = "off",
      disable_inline_completion = false,
      disable_keymaps = false,
    })
  end,
}
