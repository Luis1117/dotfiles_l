return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",   -- novo
      "hrsh7th/cmp-nvim-lsp-document-symbol",  -- novo
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "micangl/cmp-vimtex",
      "kdheepak/cmp-latex-symbols",
      "lukas-reineke/cmp-under-comparator",     -- novo
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      -- cor do ghost text
      vim.api.nvim_set_hl(0, "CmpGhostText", { fg = "#565f89", italic = true })

      local kind_icons = {
        Text          = "󰉿", Method      = "󰆧", Function    = "󰊕",
        Constructor   = "",  Field       = "󰜢", Variable    = "󰀫",
        Class         = "󰠱", Interface   = "",  Module      = "",
        Property      = "󰜢", Unit        = "󰑭", Value       = "󰎠",
        Enum          = "",  Keyword     = "󰌋", Snippet     = "",
        Color         = "󰏆", File        = "󰈙", Reference   = "󰈇",
        Folder        = "󰉋", EnumMember  = "",  Constant    = "󰏿",
        Struct        = "󰙅", Event       = "",  Operator    = "󰆕",
        TypeParameter = "",
      }

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        performance = {
          debounce         = 60,
          throttle         = 30,
          fetching_timeout = 500,
        },

        completion = {
          completeopt    = "menu,menuone,noinsert",
          keyword_length = 1,
        },

        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },

        sorting = {
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            require("cmp-under-comparator").under,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-n>"]     = cmp.mapping.select_next_item(),
          ["<C-p>"]     = cmp.mapping.select_prev_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select   = false,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        sources = cmp.config.sources({
          { name = "nvim_lsp_signature_help", priority = 1100                       },
          { name = "nvim_lsp",                priority = 1000, max_item_count = 20  },
          { name = "luasnip",                 priority = 900,  max_item_count = 15  },
          { name = "vimtex",                  priority = 850                        },
          { name = "latex_symbols",           priority = 800                        },
          { name = "path",                    priority = 500,  max_item_count = 10  },
          { name = "nvim_lua",                priority = 400                        },
        }, {
          {
            name           = "buffer",
            priority       = 250,
            max_item_count = 5,
            option         = {
              get_bufnrs = function()
                return vim.api.nvim_list_bufs()
              end,
            },
          },
        }),

        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            vim_item.kind = string.format("%s %s",
              kind_icons[vim_item.kind] or "", vim_item.kind)

            vim_item.menu = ({
              nvim_lsp_signature_help = "[Sig]",
              nvim_lsp                = "[LSP]",
              luasnip                 = "[Snip]",
              buffer                  = "[Buf]",
              path                    = "[Path]",
              nvim_lua                = "[Lua]",
              vimtex                  = "[TeX]",
              latex_symbols           = "[Sym]",
            })[entry.source.name] or ""

            local label     = vim_item.abbr
            local truncated = vim.fn.strcharpart(label, 0, 50)
            if truncated ~= label then
              vim_item.abbr = truncated .. "..."
            end

            return vim_item
          end,
        },

        experimental = {
          ghost_text = { hl_group = "CmpGhostText" },
        },
      })

      -- cmdline
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "path"    },
          { name = "cmdline" },
        },
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "nvim_lsp_document_symbol" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },

  {
    "rafamadriz/friendly-snippets",
    event = "InsertEnter",
  },
}
