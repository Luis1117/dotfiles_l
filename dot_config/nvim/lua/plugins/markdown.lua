return {
  --------------------------------------------------------------------
  -- Treesitter (necessário pro render-markdown)
  --------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if not opts.ensure_installed then opts.ensure_installed = {} end
      vim.list_extend(opts.ensure_installed, { "markdown", "markdown_inline" })
    end,
  },

  --------------------------------------------------------------------
  -- Markdown Preview no navegador
  --------------------------------------------------------------------
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    keys = {
      { "<leader>mP", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
    },
    init = function() vim.g.mkdp_auto_start = 0 end,
  },

  --------------------------------------------------------------------
  -- Render Markdown lindo (callouts, checkboxes, etc.)
  --------------------------------------------------------------------
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",  -- ← MUDADO: era "VeryLazy"
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      enabled = true,
      max_file_size = 10.0,
      file_types = { "markdown" },
      render_modes = true,
      quote = { icon = "▎", repeat_linebreak = false },
      callout = {
        note      = { raw = "[!NOTE]", rendered = "Note", highlight = "RenderMarkdownInfo" },
        tip       = { raw = "[!TIP]", rendered = "Tip", highlight = "RenderMarkdownSuccess" },
        important = { raw = "[!IMPORTANT]", rendered = "Important", highlight = "RenderMarkdownHint" },
        warning   = { raw = "[!WARNING]", rendered = "Warning", highlight = "RenderMarkdownWarn" },
        caution   = { raw = "[!CAUTION]", rendered = "Caution", highlight = "RenderMarkdownError" },
        abstract  = { raw = "[!ABSTRACT]", rendered = "Abstract", highlight = "RenderMarkdownInfo" },
        info      = { raw = "[!INFO]", rendered = "Info", highlight = "RenderMarkdownInfo" },
        todo      = { raw = "[!TODO]", rendered = "Todo", highlight = "RenderMarkdownTodo" },
        success   = { raw = "[!SUCCESS]", rendered = "Success", highlight = "RenderMarkdownSuccess" },
        question  = { raw = "[!QUESTION]", rendered = "Question", highlight = "RenderMarkdownHint" },
        failure   = { raw = "[!FAILURE]", rendered = "Failure", highlight = "RenderMarkdownError" },
        danger    = { raw = "[!DANGER]", rendered = "Danger", highlight = "RenderMarkdownError" },
        bug       = { raw = "[!BUG]", rendered = "Bug", highlight = "RenderMarkdownError" },
        example   = { raw = "[!EXAMPLE]", rendered = "Example", highlight = "RenderMarkdownHint" },
        quote     = { raw = "[!QUOTE]", rendered = "Quote", highlight = "RenderMarkdownQuote" },
      },
      sign = { enabled = true },
      checkbox = {
        enabled   = true,
        unchecked = { icon = "unchecked ", highlight = "RenderMarkdownUnchecked" },
        checked   = { icon = "checked ", highlight = "RenderMarkdownChecked" },
      },
      heading = {
        enabled = true,
        sign = true,
        icons = { "1 ", "2 ", "3 ", "4 ", "5 ", "6 " },
      },
      code = {
        enabled = true,
        sign = true,
        style = "full",
        position = "left",
        width = "block",
        border = "thin",
        left_pad = 2,
        right_pad = 2,
      },
      bullet = { enabled = true, icons = { "●", "○", "◆", "◇" } },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)

      local c = {
        blue = "#89b4fa",
        mauve = "#cba6f7",
        green = "#a6e3a1",
        yellow = "#f9e2af",
        red = "#f38ba8",
        peach = "#f5a97f",
        text = "#cdd6f4",
        surface1 = "#45475a",
      }
      vim.api.nvim_set_hl(0, "RenderMarkdownInfo", { fg = c.blue })
      vim.api.nvim_set_hl(0, "RenderMarkdownHint", { fg = c.mauve })
      vim.api.nvim_set_hl(0, "RenderMarkdownSuccess", { fg = c.green })
      vim.api.nvim_set_hl(0, "RenderMarkdownWarn", { fg = c.yellow })
      vim.api.nvim_set_hl(0, "RenderMarkdownError", { fg = c.red })
      vim.api.nvim_set_hl(0, "RenderMarkdownTodo", { fg = c.peach })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.opt_local.conceallevel = 2
          vim.opt_local.concealcursor = "nc"
        end,
      })
    end,
    keys = {
      { "<leader>mT", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Render Markdown" },
    },
  },

  --------------------------------------------------------------------
  -- Luarocks.nvim (gerencia dependências Lua)
  --------------------------------------------------------------------
  {
    "vhyrro/luarocks.nvim",
    lazy = true,  -- ← ADICIONADO!
    priority = 1001,
    opts = {
      rocks = { "magick" },
    },
  },

  --------------------------------------------------------------------
  -- IMG-CLIP: Cola e visualiza imagens
  --------------------------------------------------------------------
  {
    "HakonHarnes/img-clip.nvim",
    ft = "markdown",  -- ← MUDADO: era "VeryLazy"
    cmd = "PasteImage",  -- ← ADICIONADO
    opts = {
      default = {
        embed_image_as_base64 = false,
        prompt_for_file_name = true,
        drag_and_drop = {
          insert_mode = true,
        },
        use_absolute_path = false,
      },
      filetypes = {
        markdown = {
          url_encode_path = true,
          template = "![$CURSOR]($FILE_PATH)",
          drag_and_drop = {
            download_images = false,
          },
        },
      },
    },
    keys = {
      { "<leader>ip", "<cmd>PasteImage<cr>", desc = "Colar imagem da área de transferência" },
    },
  },

  --------------------------------------------------------------------
  -- IMAGE.NVIM: Renderização de imagens inline no Kitty
  --------------------------------------------------------------------
  {
    "3rd/image.nvim",
    ft = "markdown",  -- ← MUDADO: era "BufRead" (carregava em TUDO!)
    dependencies = { "luarocks.nvim" },
    config = function()
      local image = require("image")

      image.setup({
        backend = "kitty",
        processor = "magick_rock",
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
          },
        },
        max_width_window_percentage = 100,
        max_height_window_percentage = 100,
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
      })

      -- Habilita explicitamente
      image.enable()
    end,
    keys = {
      { "<leader>ie", "<cmd>lua require('image').enable()<cr>",  desc = "Habilitar imagens" },
      { "<leader>id", "<cmd>lua require('image').disable()<cr>", desc = "Desabilitar imagens" },
      { "<leader>ic", "<cmd>lua require('image').clear()<cr>",   desc = "Limpar imagens" },
    },
  },

  --------------------------------------------------------------------
  -- Bullets.vim & Table Mode
  --------------------------------------------------------------------
  { "bullets-vim/bullets.vim", ft = { "markdown", "text" } },
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown", "text" },
    config = function()
      vim.g.table_mode_corner = "|"
      vim.g.table_mode_delimiter = "|"
      vim.g.table_mode_auto_align = 1
    end,
  },
}
