-- ~/.config/nvim/lua/plugins/init.lua
-- CONFIGURAÇÃO OTIMIZADA PARA MÁXIMA PERFORMANCE

-- ====================================================================
-- BYTECODE CACHE (PRIMEIRO - ANTES DE TUDO)
-- ====================================================================
if vim.loader then
  vim.loader.enable()
end

-- ====================================================================
-- LEADERS
-- ====================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ====================================================================
-- DESABILITA PROVIDERS NÃO USADOS
-- ====================================================================
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- ====================================================================
-- CONFIGURAÇÕES GERAIS DE PERFORMANCE
-- ====================================================================
vim.opt.scrolloff    = 10
vim.opt.updatetime   = 300
vim.opt.timeoutlen   = 300
vim.opt.lazyredraw   = true
vim.opt.synmaxcol    = 3000
vim.opt.swapfile     = false
vim.opt.backup       = true
vim.opt.writebackup  = true
vim.opt.backupdir    = vim.fn.expand("~/.local/state/nvim/backup//")
vim.opt.undofile     = true
vim.opt.undodir      = vim.fn.expand("~/.local/state/nvim/undo//")

vim.fn.mkdir(vim.fn.expand("~/.local/state/nvim/backup"), "p")
vim.fn.mkdir(vim.fn.expand("~/.local/state/nvim/undo"), "p")

-- ====================================================================
-- OPÇÕES DE EXIBIÇÃO (modular)
-- ====================================================================
require("options")

-- ====================================================================
-- GARBAGE COLLECTION AUTOMÁTICO
-- ====================================================================
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function() collectgarbage("collect") end,
})

vim.api.nvim_create_autocmd("FocusLost", {
  callback = function() collectgarbage("collect") end,
})

-- ====================================================================
-- AUTO-CWD
-- ====================================================================
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern  = "*",
  callback = function()
    local dir = vim.fn.expand("%:p:h")
    if vim.fn.isdirectory(dir) == 1 then
      vim.cmd("silent! lcd " .. dir)
    end
  end,
})

-- ====================================================================
-- ABERTURA EXTERNA DE ARQUIVOS
-- ====================================================================
vim.ui.open = function(path)
  if type(path) == "table" then path = path[1] end
  if path:match("%.pdf$") then
    vim.fn.jobstart({ "zathura", path }, { detach = true })
    return
  end
  vim.fn.jobstart({ "xdg-open", path }, { detach = true })
end

-- ====================================================================
-- ABRIR PDF NO KITTY COM TDF
-- ====================================================================
vim.keymap.set("n", "<CR>", function()
  local file = vim.fn.expand("<cfile>")
  if file:match("%.pdf$") then
    local abs_file = vim.fn.fnamemodify(file, ":p")
    vim.fn.jobstart({
      "kitty", "@", "launch",
      "--type=tab",
      "--title=" .. vim.fn.fnamemodify(file, ":t"),
      "tdf", abs_file,
    }, { detach = true })
  else
    vim.cmd("normal! gf")
  end
end, { desc = "Abrir PDF no Kitty ou ir para arquivo" })

-- ====================================================================
-- HELPER: ROOT DO PROJETO
-- ====================================================================
_G.get_project_root = function()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir = (current_file == "" or current_file == nil)
    and vim.fn.getcwd()
    or vim.fn.fnamemodify(current_file, ":p:h")

  local git_dir = vim.fn.finddir(".git", current_dir .. ";")
  if git_dir ~= "" then
    local abs = vim.fn.fnamemodify(git_dir, ":p")
    return vim.fn.fnamemodify(abs, ":h:h")
  end
  return vim.fn.getcwd()
end

vim.api.nvim_create_user_command("ProjectRoot", function()
  print("Root do projeto: " .. get_project_root())
end, {})

-- ====================================================================
-- PLUGINS
-- ====================================================================
return {
  -- ── Mason base ────────────────────────────────────────────────────
  { "williamboman/mason.nvim", lazy = false, config = true },

  -- ── LSP Timeout ───────────────────────────────────────────────────
  {
    "hinell/lsp-timeout.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    event        = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.g.lspTimeoutConfig = {
        stopTimeout  = 1000 * 60 * 5,
        startTimeout = 10000,
        silent       = false,
        filetypes    = { ignore = {} },
      }
    end,
  },

  -- ── Faster.nvim ───────────────────────────────────────────────────
  {
    "pteroctopus/faster.nvim",
    event = "VeryLazy",
    opts  = {
      behaviours = {
        bigfile = {
          on       = true,
          features = {
            treesitter       = { on = true, defer = false },
            lsp              = { on = true, defer = false },
            indent_blankline = { on = true, defer = false },
            syntax           = { on = true, defer = true },
            filetype         = { on = true, defer = true },
          },
          filesize    = 1,
          ignored_fts = { "tex", "latex" },
        },
      },
    },
  },

  -- ── Conform base ──────────────────────────────────────────────────
  { "stevearc/conform.nvim" },

  -- ── Tema: Everforest Dark Medium ──────────────────────────────────
  {

    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- 🌙 dark mais suave

        transparent_background = true, -- mantém teu estilo atual

        styles = {
          comments = { "italic" },
          keywords = { "bold" },
          functions = { "bold" },
        },

        integrations = {
          treesitter = true,
          illuminate = true,
          telescope = true,
          native_lsp = {
            enabled = true,
          },
      },
    })
    vim.cmd.colorscheme("catppuccin")
  end,},

  -- ── vim-illuminate ────────────────────────────────────────────────
  {
    "RRethy/vim-illuminate",
    event  = { "BufReadPost", "BufNewFile" },
    config = function()
      require("illuminate").configure({
        delay        = 80,
        providers    = { "treesitter", "lsp", "regex" },
        under_cursor = true,
        filetypes_denylist = {
          "neo-tree",
          "dashboard",
          "trouble",
          "aerial",
          "toggleterm",
          "TelescopePrompt",
          "harpoon",
        },
      })

      local function set_illuminate_hl()
        vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#3c474d" })
        vim.api.nvim_set_hl(0, "IlluminatedWordRead",  { bg = "#3c474d" })
        vim.api.nvim_set_hl(0, "IlluminatedWordWrite", {
          bg        = "#374247",
          underline = true,
          sp        = "#83c092",
        })
      end

      set_illuminate_hl()

      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_illuminate_hl,
      })

      vim.keymap.set("n", "]]", require("illuminate").goto_next_reference,
        { desc = "Illuminate: próxima ocorrência" })
      vim.keymap.set("n", "[[", require("illuminate").goto_prev_reference,
        { desc = "Illuminate: ocorrência anterior" })
    end,
  },

  -- ── Treesitter ────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then return end
      configs.setup({
        ensure_installed = {
          "python", "lua", "bash", "c",
          "latex", "julia", "markdown", "markdown_inline",
          "vim", "vimdoc", "query",
        },
        auto_install = true,
        highlight = {
          enable  = true,
          disable = function(_, buf)
            local ok_stat, stats = pcall(
              vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf)
            )
            if ok_stat and stats and stats.size > 500 * 1024 then
              return true
            end
          end,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end,
  },

  -- ── Markdown Preview ──────────────────────────────────────────────
  {
    "iamcco/markdown-preview.nvim",
    cmd   = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft    = { "markdown" },
    build = "cd app && npm install",
    keys  = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
    },
  },

  -- ── Easy Align ────────────────────────────────────────────────────
  {
    "junegunn/vim-easy-align",
    keys = {
      { "ga", mode = { "n", "x" }, "<Plug>(EasyAlign)", desc = "EasyAlign" },
    },
  },

  { "dpezto/gnuplot.vim", ft = { "gnuplot" } },

  -- ── Imports ───────────────────────────────────────────────────────
  { import = "plugins.lsp"        },
  { import = "plugins.image"      },
  { import = "plugins.python"     },
  { import = "plugins.latex"      },
  { import = "plugins.julia"      },
  { import = "plugins.git"        },
  { import = "plugins.c-dev"      },
  { import = "plugins.telescope"  },
  { import = "plugins.frecency"   },
  { import = "plugins.harpoon"    },
  { import = "plugins.neo-tree"   },
  { import = "plugins.nvumi"      },
  { import = "plugins.colorizer"  },  -- novo
}
