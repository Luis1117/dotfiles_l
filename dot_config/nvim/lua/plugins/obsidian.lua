-- ~/.config/nvim/lua/plugins/obsidian.lua
return {
  "epwalsh/obsidian.nvim",
  version = "*",
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
  },

  config = function()
    local obsidian = require("obsidian")

    obsidian.setup({
      workspaces = {
        {
          name = "personal",
          path = "~/Documentos/Obsidian Vault",
        },
      },

      notes_subdir = "inbox",

      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        alias_format = "%d de %B de %Y",
      },

      templates = {
        subdir = "Templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
        substitutions = {
          weekday = function() return os.date("%A") end,
        },
      },

      attachments = {
        img_folder = "anexos",
        img_name_func = function()
          return string.format("%s-", os.date("%Y%m%d-%H%M%S"))
        end,
      },

      completion = { nvim_cmp = true, min_chars = 3 },

      note_id_func = function(title)
        if title then
          return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        end
        return os.date("%Y%m%d%H%M%S")
      end,

      preferred_link_style = "wiki",
      finder = "telescope.nvim",

      follow_url_func = function(url)
        vim.fn.jobstart({ "xdg-open", url })
      end,

      ui = {
        enable = false,
      },

      mappings = {},
    })

    -- =============================================
    -- AUTOCMDS
    -- =============================================
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
      pattern = "*.md",
      callback = function()
        local path = vim.api.nvim_buf_get_name(0)
        if path:find(vim.fn.expand("~/Documentos/Obsidian Vault"), 1, true) then
          vim.opt_local.conceallevel = 2
          vim.opt_local.concealcursor = "nc"
        end
      end,
    })

    vim.api.nvim_create_autocmd("BufLeave", {
      pattern = "*.md",
      callback = function()
        if vim.bo.modified then vim.cmd("silent! write") end
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.opt_local.spell = true
        vim.opt_local.spelllang = { "pt_br", "en_us" }
      end,
    })
  end,

  -- =============================================
  -- KEYMAPS - SEM CONFLITOS
  -- =============================================
  keys = {
    -- Navegação básica
    { "<leader>ch", function() require("obsidian").util.toggle_checkbox() end, desc = "Toggle Checkbox" },
    { "[o",         function() require("obsidian").util.goto_prev_link() end,  desc = "Previous Link" },
    { "]o",         function() require("obsidian").util.goto_next_link() end,  desc = "Next Link" },
    { "gf",         function() return require("obsidian").util.gf_passthrough() end, expr = true, buffer = true, desc = "Follow Link" },

    -- Busca e navegação (grupo o + letra única)
    { "<leader>oq", "<cmd>ObsidianQuickSwitch<cr>",   desc = "Quick Switch" },
    { "<leader>os", "<cmd>ObsidianSearch<cr>",        desc = "Buscar notas" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<cr>",     desc = "Backlinks" },
    { "<leader>og", "<cmd>ObsidianTags<cr>",          desc = "Tags" },
    { "<leader>oc", "<cmd>ObsidianTOC<cr>",           desc = "Table of Contents" },
    
    -- ⭐ MUDADO: <leader>oL para Links (evita conflito com Oil <leader>ol)
    { "<leader>oL", "<cmd>ObsidianLinks<cr>",         desc = "Links da nota" },

    -- Criar notas (grupo o + n + letra)
    { "<leader>on",  "<cmd>ObsidianNew<cr>",          desc = "Nova nota" },
    { "<leader>onf", "<cmd>ObsidianNewFromTemplate<cr>", desc = "Nota de template" },
    { "<leader>ont", "<cmd>ObsidianToday<cr>",        desc = "Nota de hoje" },
    { "<leader>ony", "<cmd>ObsidianYesterday<cr>",    desc = "Nota de ontem" },
    { "<leader>onm", "<cmd>ObsidianTomorrow<cr>",     desc = "Nota de amanhã" },

    -- Operações na nota (grupo o + r/w/T)
    { "<leader>or", "<cmd>ObsidianRename<cr>",        desc = "Renomear nota" },
    { "<leader>ow", "<cmd>ObsidianWorkspace<cr>",     desc = "Trocar workspace" },
    { "<leader>oT", "<cmd>ObsidianTemplate<cr>",      desc = "Inserir template" },
    { "<leader>oO", "<cmd>ObsidianOpen<cr>",          desc = "Abrir no Obsidian app" },

    -- Imagens (grupo o + i + letra)
    { "<leader>oip", "<cmd>ObsidianPasteImg<cr>",     desc = "Colar imagem" },
    { "<leader>oio", function()
      local line = vim.api.nvim_get_current_line()
      local image = line:match('!%[.-%]%((.-)%)') or line:match('%[%[(.-)%]%]')
      
      if not image then
        vim.notify("❌ Nenhuma imagem na linha", vim.log.levels.INFO)
        return
      end
      
      image = image:gsub('^%[%[', ''):gsub('%]%]$', '')
      
      local vault = vim.fn.expand("~/Documentos/Obsidian Vault")
      local cur_dir = vim.fn.expand("%:p:h")
      
      local paths = {
        cur_dir .. "/anexos/" .. image,
        cur_dir .. "/" .. image,
        vault .. "/anexos/" .. image,
        vault .. "/" .. image,
      }
      
      for _, p in ipairs(paths) do
        if vim.fn.filereadable(p) == 1 then
          vim.fn.jobstart({ "kitty", "+kitten", "icat", p }, { detach = true })
          vim.notify("🖼️  " .. vim.fn.fnamemodify(p, ":t"), vim.log.levels.INFO)
          return
        end
      end
      
      vim.notify("❌ Imagem não encontrada: " .. image, vim.log.levels.WARN)
    end, desc = "Abrir imagem" },
    
    { "<leader>oiy", function()
      local line = vim.api.nvim_get_current_line()
      local image = line:match('!%[.-%]%((.-)%)') or line:match('%[%[(.-)%]%]')
      
      if not image then
        vim.notify("❌ Nenhuma imagem na linha", vim.log.levels.WARN)
        return
      end
      
      image = image:gsub('^%[%[', ''):gsub('%]%]$', '')
      vim.fn.setreg("+", image)
      vim.notify("📋 Copiado: " .. image, vim.log.levels.INFO)
    end, desc = "Copiar path da imagem" },

    -- Visual mode - Links (grupo o + v + letra)
    { "<leader>ovx", "<cmd>ObsidianExtractNote<cr>",  mode = "v", desc = "Extrair para nova nota" },
    { "<leader>ovl", "<cmd>ObsidianLink<cr>",         mode = "v", desc = "Linkar seleção" },
    { "<leader>ovn", "<cmd>ObsidianLinkNew<cr>",      mode = "v", desc = "Linkar para nova nota" },
  },
}
