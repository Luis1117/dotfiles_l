return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  opts = function()
    local logo = [[
      ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
      ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
      ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
      ██║╚██╗██║██╔══╝  ██║   ██║██║   ██║██║██║╚██╔╝██║
      ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
      ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
    ]]
    logo = string.rep("\n", 8) .. logo .. "\n\n"
    local opts = {
      theme = "doom",
      hide = { statusline = false },
      config = {
        header = vim.split(logo, "\n"),
        center = {
          -- Buscar arquivo (usando root do projeto)
          {
            action = function()
              require("telescope.builtin").find_files({ 
                cwd = get_project_root(),
                hidden = true,
              })
            end,
            desc = " Buscar arquivo",
            icon = " ",
            key = "f"
          },
          -- Novo arquivo
          { 
            action = "ene | startinsert",
            desc = " Novo arquivo",
            icon = " ",
            key = "n"
          },
          -- Recentes (usando root do projeto)
          {
            action = function()
              require("telescope.builtin").oldfiles({ 
                cwd = get_project_root() 
              })
            end,
            desc = " Recentes",
            icon = " ",
            key = "r"
          },
          -- Buscar texto (usando root do projeto)
          {
            action = function()
              require("telescope.builtin").live_grep({ 
                cwd = get_project_root() 
              })
            end,
            desc = " Buscar texto",
            icon = " ",
            key = "g"
          },
          -- Buffers
          { 
            action = "Telescope buffers",
            desc = " Buffers",
            icon = " ",
            key = "b"
          },
          -- Notas Obsidian
          {
            action = function()
              if vim.fn.exists(":ObsidianQuickSwitch") == 2 then
                vim.cmd("ObsidianQuickSwitch")
              else
                vim.notify("Obsidian.nvim não carregado ainda", vim.log.levels.WARN)
              end
            end,
            desc = " Notas Obsidian",
            icon = " ",
            key = "o",
          },
          -- Lazy
          { 
            action = "Lazy",
            desc = " Lazy",
            icon = "󰒲 ",
            key = "p"
          },
          -- Sair
          { 
            action = "qa",
            desc = " Sair",
            icon = " ",
            key = "q"
          },
        },
        footer = function()
          local stats = require("lazy").stats()
          local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
          return { "⚡ Neovim carregado em " .. ms .. "ms com " .. stats.loaded .. "/" .. stats.count .. " plugins" }
        end,
      },
    }
    return opts
  end,
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
