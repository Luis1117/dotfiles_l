return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Neo-tree" },
  },
  opts = {
    close_if_last_window = true,
    window = {
      width = 35,
      position = "right",
      mappings = {
        -- ENTER customizado: Abre PDF com tdf em nova aba do Kitty
        ["<cr>"] = {
          function(state)
            local node = state.tree:get_node()
            
            -- Se for arquivo PDF
            if node.type == "file" and node.name:match('%.pdf$') then
              vim.fn.jobstart({
                'kitty', '@', 'launch',
                '--type=tab',
                '--title=' .. node.name,
                'tdf', node.path
              }, { detach = true })
              
              vim.notify("📄 Abrindo PDF: " .. node.name, vim.log.levels.INFO)
            else
              -- Comportamento padrão para outros arquivos/pastas
              require("neo-tree.sources.filesystem.commands").open(state)
            end
          end,
          desc = "Abrir (PDF em Kitty com tdf, outros normal)"
        },
        
        ["l"] = "open",
        ["h"] = "close_node",
        ["a"] = "add",
        ["d"] = "delete",
        ["r"] = "rename",
        ["q"] = "close_window",
        ["-"] = "navigate_up",
        ["H"] = "toggle_hidden",
        ["P"] = "toggle_preview",
        ["?"] = "show_help",
      },
    },
    filesystem = {
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
    },
  },
}
