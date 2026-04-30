-- nvim/lua/plugins/trouble.lua
return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "Trouble",
  keys = {
    {
      "<leader>xx",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Diagnósticos (projeto)",
    },
    {
      "<leader>xX",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Diagnósticos (arquivo atual)",
    },
    {
      "<leader>xs",
      "<cmd>Trouble symbols toggle focus=false<cr>",
      desc = "Símbolos do arquivo",
    },
    {
      "<leader>xl",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "LSP refs / definições",
    },
    {
      "<leader>xL",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Location list",
    },
    {
      "<leader>xq",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Quickfix list",
    },
    {
      "<leader>xt",
      "<cmd>Trouble todo toggle<cr>",
      desc = "TODOs do projeto",
    },
    -- Navegar entre itens sem abrir a janela do trouble
    {
      "[x",
      function() require("trouble").prev({ skip_groups = true, jump = true }) end,
      desc = "Trouble: item anterior",
    },
    {
      "]x",
      function() require("trouble").next({ skip_groups = true, jump = true }) end,
      desc = "Trouble: próximo item",
    },
    {
      "[X",
      function() require("trouble").first({ skip_groups = true, jump = true }) end,
      desc = "Trouble: primeiro item",
    },
    {
      "]X",
      function() require("trouble").last({ skip_groups = true, jump = true }) end,
      desc = "Trouble: último item",
    },
  },
  config = function()
    require("trouble").setup({
      modes = {
        -- modo padrão de diagnósticos
        diagnostics = {
          auto_close   = false,
          auto_preview = true,
          auto_refresh = true,
          focus        = false,   -- não rouba o foco ao abrir
        },
        -- modo de símbolos (outline do arquivo)
        symbols = {
          focus = false,
          win = { position = "right", size = 0.3 },
          filter = {
            kind = {
              "Class", "Function", "Method",
              "Constructor", "Interface", "Module",
              "Struct", "Trait", "Field", "Property",
            },
          },
        },
        -- integração com todo-comments
        todo = {
          mode   = "todo",
          filter = { tag = { "TODO", "FIXME", "HACK", "WARN", "QWIP" } },
        },
      },
      icons = {
        indent = {
          top        = "│ ",
          middle     = "├╴",
          last       = "└╴",
          fold_open  = " ",
          fold_closed = " ",
          ws         = "  ",
        },
        folder_closed = " ",
        folder_open   = " ",
        kinds = {
          Array         = " ",
          Boolean       = "󰨙 ",
          Class         = " ",
          Constant      = "󰏿 ",
          Constructor   = " ",
          Enum          = " ",
          EnumMember    = " ",
          Event         = " ",
          Field         = " ",
          File          = " ",
          Function      = "󰊕 ",
          Interface     = " ",
          Key           = " ",
          Method        = "󰊕 ",
          Module        = " ",
          Namespace     = "󰦮 ",
          Null          = " ",
          Number        = "󰎠 ",
          Object        = " ",
          Operator      = " ",
          Package       = " ",
          Property      = " ",
          String        = " ",
          Struct        = "󰆼 ",
          Type          = " ",
          TypeParameter = " ",
          Variable      = "󰀫 ",
        },
      },
    })
  end,
}
