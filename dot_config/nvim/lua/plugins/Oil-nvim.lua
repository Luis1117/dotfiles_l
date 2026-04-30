return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local oil = require("oil")

    oil.setup({
      default_file_explorer = false,

      columns = {
        "icon",
      },

      buf_options = {
        buflisted = false,
        bufhidden = "hide",
      },

      win_options = {
        wrap = false,
        signcolumn = "no",
        cursorcolumn = false,
        foldcolumn = "0",
        spell = false,
        list = false,
        conceallevel = 3,
        concealcursor = "nvic",
      },

      view_options = {
        show_hidden = false,
        is_hidden_file = function(name, bufnr)
          return vim.startswith(name, ".")
        end,
        is_always_hidden = function(name, bufnr)
          return name == ".." or name == ".git"
        end,
        natural_order = true,
        sort = {
          { "type", "asc" },
          { "name", "asc" },
        },
      },

      keymaps = {
        ["g?"] = "actions.show_help",

        -- ENTER CUSTOMIZADO: Abre PDF com tdf em nova aba do Kitty
        ["<CR>"] = {
          callback = function()
            local entry = oil.get_cursor_entry()

            if entry and entry.type == "file" then
              local filename = entry.name

              if filename:match('%.pdf$') then
                local dir = oil.get_current_dir()
                local filepath = dir .. filename

                vim.fn.jobstart({
                  'kitty', '@', 'launch',
                  '--type=tab',
                  '--title=' .. filename,
                  'tdf', filepath
                }, { detach = true })

                vim.notify("📄 Abrindo PDF: " .. filename, vim.log.levels.INFO)
                return
              end
            end

            require("oil.actions").select.callback()
          end,
          desc = "Abrir (PDF em Kitty com tdf, outros normal)"
        },

        -- Abrir em split/vsplit/tab (teclas locais do Oil)
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-s>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<M-p>"] = "actions.preview",
        ["q"]     = "actions.close",
        ["R"]     = "actions.refresh",
        ["-"]     = "actions.parent",
        ["_"]     = "actions.open_cwd",
        ["`"]     = "actions.cd",
        ["~"]     = "actions.tcd",
        ["gs"]    = "actions.change_sort",
        ["gx"]    = "actions.open_external",
        ["g."]    = "actions.toggle_hidden",
        ["g\\"]   = "actions.toggle_trash",

        ["gh"] = {
          callback = function()
            oil.open(vim.fn.expand("~"))
          end,
          desc = "Ir para HOME",
        },

        ["a"] = {
          callback = function()
            local dir = oil.get_current_dir()
            vim.ui.input({
              prompt = "Criar (termina com / para pasta): ",
              default = "",
            }, function(name)
              if name and name ~= "" then
                local path = dir .. name
                if vim.endswith(name, "/") then
                  vim.fn.mkdir(path, "p")
                  vim.notify("✓ Pasta criada: " .. name, vim.log.levels.INFO)
                else
                  local parent = vim.fn.fnamemodify(path, ":h")
                  vim.fn.mkdir(parent, "p")
                  vim.fn.writefile({}, path)
                  vim.notify("✓ Arquivo criado: " .. name, vim.log.levels.INFO)
                end
                oil.open(dir)
              end
            end)
          end,
          desc = "Criar arquivo/pasta",
        },

        ["yp"] = {
          callback = function()
            local entry = oil.get_cursor_entry()
            if entry then
              local dir = oil.get_current_dir()
              local path = dir .. entry.name
              vim.system({"wl-copy", path})
              vim.fn.setreg('"', path)
              vim.notify("📋 Copiado (absoluto): " .. path, vim.log.levels.INFO)
            end
          end,
          desc = "Copiar caminho absoluto do item",
        },

        ["yr"] = {
          callback = function()
            local entry = oil.get_cursor_entry()
            if entry then
              local dir = oil.get_current_dir()
              local path = dir .. entry.name
              local relative = vim.fn.fnamemodify(path, ":.")
              vim.system({"wl-copy", relative})
              vim.fn.setreg('"', relative)
              vim.notify("📋 Copiado (relativo): " .. relative, vim.log.levels.INFO)
            end
          end,
          desc = "Copiar caminho relativo do item",
        },

        ["yn"] = {
          callback = function()
            local entry = oil.get_cursor_entry()
            if entry then
              vim.system({"wl-copy", entry.name})
              vim.fn.setreg('"', entry.name)
              vim.notify("📋 Copiado nome: " .. entry.name, vim.log.levels.INFO)
            end
          end,
          desc = "Copiar nome do item",
        },

        ["yd"] = {
          callback = function()
            local dir = oil.get_current_dir()
            if dir then
              vim.system({"wl-copy", dir})
              vim.fn.setreg('"', dir)
              vim.notify("📋 Pasta copiada (absoluto): " .. dir, vim.log.levels.INFO)
            end
          end,
          desc = "Copiar caminho absoluto da pasta atual",
        },

        ["yD"] = {
          callback = function()
            local dir = oil.get_current_dir()
            if dir then
              local relative = vim.fn.fnamemodify(dir, ":.")
              vim.system({"wl-copy", relative})
              vim.fn.setreg('"', relative)
              vim.notify("📋 Pasta copiada (relativo): " .. relative, vim.log.levels.INFO)
            end
          end,
          desc = "Copiar caminho relativo da pasta atual",
        },

        -- Terminal na pasta atual (tecla local do Oil)
        ["T"] = {
          callback = function()
            local dir = oil.get_current_dir()
            vim.cmd("tabnew")
            vim.cmd("terminal")
            vim.cmd("cd " .. dir)
            vim.cmd("startinsert")
          end,
          desc = "Abrir terminal aqui",
        },
      },

      delete_to_trash = true,
      skip_confirm_for_simple_edits = false,
      prompt_save_on_select_new_entry = true,
      cleanup_delay_ms = 2000,

      lsp_file_methods = {
        timeout_ms = 1000,
        autosave_changes = false,
      },

      constrain_cursor = "editable",
      watch_for_changes = true,

      keymaps_help = { border = "rounded" },

      float = {
        padding = 2,
        max_width = 90,
        max_height = 30,
        border = "rounded",
        win_options = { winblend = 0 },
      },

      preview = {
        max_width = 0.5,
        min_width = { 40, 0.3 },
        max_height = 0.8,
        min_height = { 10, 0.1 },
        border = "rounded",
        win_options = { winblend = 0 },
      },
    })

    -- Keymaps globais — sem conflito com Obsidian
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Oil: Abrir pasta pai" })
    vim.keymap.set("n", "<leader>-", oil.toggle_float, { desc = "Oil: Float" })

    -- Autocommands
    local oil_augroup = vim.api.nvim_create_augroup("OilOptimizations", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = oil_augroup,
      pattern = "oil",
      callback = function(args)
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
      end,
    })

    vim.api.nvim_create_autocmd("BufEnter", {
      group = oil_augroup,
      callback = function()
        if vim.fn.isdirectory(vim.fn.expand("%")) == 1 then
          oil.open()
        end
      end,
    })
  end,
}
