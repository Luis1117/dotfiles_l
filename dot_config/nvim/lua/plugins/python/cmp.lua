-- lua/plugins/python/cmp.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- nvim-cmp: autocomplete Python (LSP, snippets, buffer, path, lua)
-- Melhorias: signature help, lsp-kind icons, prioridades ajustadas
-- ─────────────────────────────────────────────────────────────────────────────

return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help", -- assinatura de função ao digitar
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",               -- ícones mais completos
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        performance = {
          debounce         = 40,   -- mais responsivo que 60
          throttle         = 20,
          fetching_timeout = 400,
        },

        completion = {
          completeopt  = "menu,menuone,noinsert",
          keyword_length = 1,
        },

        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
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
          { name = "nvim_lsp",               priority = 1000, max_item_count = 20 },
          { name = "nvim_lsp_signature_help",priority = 950  },  -- assinatura
          { name = "luasnip",                priority = 750,  max_item_count = 10 },
          { name = "path",                   priority = 500,  max_item_count = 10 },
          { name = "nvim_lua",               priority = 400  },
        }, {
          {
            name = "buffer",
            priority = 250,
            max_item_count = 5,
            option = {
              get_bufnrs = function()
                return vim.api.nvim_list_bufs()
              end,
            },
          },
        }),

        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = lspkind.cmp_format({
            mode    = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
            menu = {
              nvim_lsp               = "[LSP]",
              nvim_lsp_signature_help= "[Sig]",
              luasnip                = "[Snip]",
              buffer                 = "[Buf]",
              path                   = "[Path]",
              nvim_lua               = "[Lua]",
            },
          }),
        },

        experimental = {
          ghost_text = { hl_group = "Comment" },
        },
      })

      -- ── Cmdline ────────────────────────────────────────────────────────────
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "path" },
          { name = "cmdline" },
        },
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })
    end,
  },

  { "onsails/lspkind.nvim",            lazy = true },
  { "rafamadriz/friendly-snippets",    event = "InsertEnter" },
}
