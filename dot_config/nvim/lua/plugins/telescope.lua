-- ~/.config/nvim/lua/plugins/telescope.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Telescope + telescope-bibtex
-- Busca .bib apenas no projeto atual (pasta do arquivo + raiz Git/cwd)
-- ─────────────────────────────────────────────────────────────────────────────

-- Raiz do projeto Git, ou cwd se não houver Git (ignora config do nvim)
local function get_project_root()
  local current_file = vim.fn.expand("%:p:h")
  local nvim_config  = vim.fn.expand("~/.config/nvim")
  local git_root     = vim.fn.systemlist(
    "git -C " .. vim.fn.shellescape(current_file) .. " rev-parse --show-toplevel"
  )[1]
  if vim.v.shell_error == 0 and git_root and git_root ~= nvim_config then
    return git_root
  end
  return vim.fn.getcwd()  -- onde o Neovim foi aberto
end

_G.get_project_root = get_project_root

-- ─────────────────────────────────────────────────────────────────────────────
-- Descobre todos os .bib do projeto atual:
--   1. Pasta do arquivo aberto no buffer
--   2. Raiz do Git ou cwd (onde o Neovim foi aberto)
-- Rápido — não varre o sistema inteiro.
-- ─────────────────────────────────────────────────────────────────────────────
local function find_project_bibs()
  local seen      = {}
  local bib_files = {}

  local function add(file)
    local real = vim.fn.resolve(vim.fn.fnamemodify(file, ":p"))
    if real ~= "" and not seen[real] and vim.fn.filereadable(real) == 1 then
      seen[real] = true
      table.insert(bib_files, real)
    end
  end

  -- Camada 1: pasta do arquivo atual
  for _, f in ipairs(vim.fn.glob(vim.fn.expand("%:p:h") .. "/*.bib", false, true)) do
    add(f)
  end

  -- Camada 2: raiz do Git ou cwd (recursivo)
  local root = get_project_root()
  for _, f in ipairs(vim.fn.glob(root .. "/**/*.bib", false, true)) do
    add(f)
  end

  return bib_files
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Picker: lista os .bib do projeto e abre o picker de entradas no escolhido
-- ─────────────────────────────────────────────────────────────────────────────
local function pick_bib_and_search()
  local pickers      = require("telescope.pickers")
  local finders      = require("telescope.finders")
  local conf         = require("telescope.config").values
  local actions      = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local bib_files = find_project_bibs()

  if #bib_files == 0 then
    vim.notify("Nenhum .bib encontrado no projeto!", vim.log.levels.WARN)
    return
  end

  -- Só um .bib: abre direto sem picker intermediário
  if #bib_files == 1 then
    require("telescope").extensions.bibtex.bibtex({ search_file = bib_files[1] })
    return
  end

  local home = vim.fn.expand("~")

  pickers.new({}, {
    prompt_title = string.format("Escolher .bib (%d encontrados)", #bib_files),
    finder = finders.new_table({
      results = bib_files,
      entry_maker = function(file)
        local display = file:gsub(home, "~")  -- mostra ~/caminho legível
        return { value = file, display = display, ordinal = display }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local sel = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if sel then
          require("telescope").extensions.bibtex.bibtex({ search_file = sel.value })
        end
      end)
      return true
    end,
  }):find()
end

_G.pick_bib_and_search = pick_bib_and_search

-- ─────────────────────────────────────────────────────────────────────────────

return {

  -- ── 1. Telescope core ─────────────────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    cmd          = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },

    keys = {
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files({ cwd = get_project_root(), hidden = true })
        end,
        desc = "Find Files (Root)",
      },
      {
        "<leader>fg",
        function()
          require("telescope.builtin").live_grep({ cwd = get_project_root() })
        end,
        desc = "Live Grep (Root)",
      },
      {
        "<leader>fd",
        function()
          require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h"), hidden = true })
        end,
        desc = "Find Files (dir atual)",
      },
      {
        "<leader>fD",
        function()
          require("telescope.builtin").live_grep({ cwd = vim.fn.expand("%:p:h") })
        end,
        desc = "Live Grep (dir atual)",
      },
      {
        "<leader>fb",
        "<cmd>Telescope buffers<cr>",
        desc = "Find Buffers",
      },
      {
        "<leader>r",
        function()
          require("telescope.builtin").oldfiles({ cwd = get_project_root() })
        end,
        desc = "Arquivos recentes",
      },
      {
        "<leader>E",
        function()
          require("telescope.builtin").live_grep({ cwd = get_project_root() })
        end,
        desc = "Buscar texto",
      },
      {
        "<leader>h",
        "<cmd>Telescope help_tags<cr>",
        desc = "Help",
      },
      {
        "<leader>f/",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find()
        end,
        desc = "Grep no buffer atual",
      },
      {
        "<leader>f*",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find({
            default_text = vim.fn.expand("<cword>"),
          })
        end,
        desc = "Buscar palavra no buffer atual",
      },
    },

    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "^.git/", "node_modules", "__pycache__" },
          layout_config = {
            horizontal = { preview_width = 0.5 },
          },
        },
        extensions = {
          bibtex = {
            global_files            = {},   -- tudo resolvido dinamicamente
            depth                   = 2,
            format                  = "",   -- detecta filetype: tex→\cite{}, md→[@]
            search_keys             = { "author", "year", "title" },
            citation_format         = "{{author}} ({{year}}), {{title}}.",
            citation_trim_firstname = true,
            citation_max_auth       = 2,
            context                 = true,
            context_fallback        = true,
            wrap                    = false,
          },
        },
      })
      require("telescope").load_extension("bibtex")
    end,
  },

  -- ── 2. telescope-bibtex ───────────────────────────────────────────────────
  -- Keymaps no grupo <leader>l (mesmo grupo do latex.lua)
  -- latex.lua usa: lv ll lc ls lL lk lK le lT lb
  -- bibtex usa:    lB lbs  ← livres, sem conflito
  {
    "nvim-telescope/telescope-bibtex.nvim",
    ft           = { "tex", "latex", "bib", "markdown" },
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      -- Detecção automática pelo contexto do projeto
      {
        "<leader>lB",
        "<cmd>Telescope bibtex<cr>",
        desc = "LaTeX: BibTeX (auto)",
      },
      -- Picker: lista os .bib do projeto atual para escolher
      {
        "<leader>lbs",
        function() pick_bib_and_search() end,
        desc = "LaTeX: BibTeX (escolher .bib)",
      },
    },
  },

}
