return {
  "jghauser/papis.nvim",
  dependencies = {
    "kkharji/sqlite.lua",
    "MunifTanjim/nui.nvim",
    "nvim-telescope/telescope.nvim",
  },
  ft = { "markdown", "norg", "yaml", "typst", "tex" },
  config = function()
    require("papis").setup({
      init_filetypes = { "markdown", "norg", "yaml", "typst", "tex" },
      papis_cmd_base = { "papis", "-l", "Zotero" },
      ["search"] = { enable = true },
      ["at-cursor"] = { enable = true },
      ["formatter"] = { enable = false },
    })

    vim.keymap.set("n", "<leader>zs", "<cmd>Papis search<cr>",              { desc = "Papis: search" })
    vim.keymap.set("n", "<leader>zo", "<cmd>Papis at-cursor open-file<cr>", { desc = "Papis: open file" })
    vim.keymap.set("n", "<leader>zn", "<cmd>Papis at-cursor open-note<cr>", { desc = "Papis: open note" })
  end,
}


