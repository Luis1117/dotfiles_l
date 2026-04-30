return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",  -- ⭐ Lazy load para startup mais rápido
  opts = {
    options = {
      theme = "auto",
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      globalstatus = true,
      disabled_filetypes = {
        statusline = { "dashboard", "alpha", "starter" },
      },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { 
        "branch",
        {
          "diff",
          symbols = { added = " ", modified = " ", removed = " " },
        },
        {
          "diagnostics",
          sources = { "nvim_lsp" },
          symbols = { error = " ", warn = " ", info = " ", hint = " " },
        },
      },
      lualine_c = { 
        { 
          "filename", 
          path = 1,  -- Caminho relativo
          symbols = {
            modified = " ●",
            readonly = " ",
            unnamed = "[No Name]",
          },
        },
      },
      lualine_x = {
        {
          -- ⭐ Mostra LSP ativo
          function()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients == 0 then
              return ""
            end
            local names = {}
            for _, client in ipairs(clients) do
              table.insert(names, client.name)
            end
            return " " .. table.concat(names, ", ")
          end,
          color = { fg = "#7aa2f7" },
        },

       -- ⭐ Contador de cursores (multicursor.nvim)
        {
          function()
            if _G.mc_status then
              return _G.mc_status()
            end
            return ""
          end,
          color = { fg = "#c678dd" },
        },

        "encoding",
        "fileformat",
        "filetype",
      },
      lualine_y = { 
        "progress",
        {
          -- ⭐ Mostra tamanho do arquivo
          function()
            local size = vim.fn.getfsize(vim.fn.expand("%"))
            if size < 1024 then
              return size .. "B"
            elseif size < 1048576 then
              return string.format("%.1fK", size / 1024)
            else
              return string.format("%.1fM", size / 1048576)
            end
          end,
        },
      },
      lualine_z = { 
        "location",
        {
          -- ⭐ Mostra total de linhas
          function()
            return vim.fn.line("$") .. " lines"
          end,
        },
      },
    },
    -- ⭐ REMOVIDO "nvim-tree", adicionado "yazi" (se quiser)
    extensions = { "lazy", "mason", "toggleterm" },
  },
}
