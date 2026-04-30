-- ~/.config/nvim/lua/plugins/frecency.lua
return {
  "nvim-telescope/telescope-frecency.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "tami5/sqlite.lua",
  },
  keys = {
    {
      "<leader>fr",
      "<cmd>Telescope frecency<CR>",
      desc = "Arquivos mais usados (Frecency)",
    },
  },
  config = function()
    require("telescope").load_extension("frecency")
  end,
}
