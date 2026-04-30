-- nvim/lua/plugins/folding.lua
return {
  "kevinhwang91/nvim-ufo",
  dependencies = {
    "kevinhwang91/promise-async",
    "nvim-treesitter/nvim-treesitter",
  },
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    { "zR", function() require("ufo").openAllFolds()          end, desc = "Abrir todos os folds"    },
    { "zM", function() require("ufo").closeAllFolds()         end, desc = "Fechar todos os folds"   },
    { "zr", function() require("ufo").openFoldsExceptKinds()  end, desc = "Abrir folds exceto imports" },
    { "zm", function() require("ufo").closeFoldsWith()        end, desc = "Fechar folds por nível"  },
    { "K",  function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end, desc = "Peek fold / Hover LSP" },
  },
  config = function()
    vim.o.foldcolumn     = "1"
    vim.o.foldlevel      = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable     = true

    -- Handler customizado pra exibir "··· N linhas ···" no fold
    local handler = function(virtText, lnum, endLnum, width, truncate)
      local newVirtText = {}
      local suffix      = ("  %d linhas "):format(endLnum - lnum)
      local sufWidth    = vim.fn.strdisplaywidth(suffix)
      local targetWidth = width - sufWidth
      local curWidth    = 0

      for _, chunk in ipairs(virtText) do
        local chunkText  = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
          table.insert(newVirtText, chunk)
        else
          chunkText = truncate(chunkText, targetWidth - curWidth)
          table.insert(newVirtText, { chunkText, chunk[2] })
          chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if curWidth + chunkWidth < targetWidth then
            suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
          end
          break
        end
        curWidth = curWidth + chunkWidth
      end

      table.insert(newVirtText, { suffix, "UfoFoldedEllipsis" })
      return newVirtText
    end

    -- Detecta se o parser treesitter está instalado
    local function ts_available(filetype)
      local ok = pcall(function()
        vim.treesitter.language.inspect(filetype)
      end)
      return ok
    end

    require("ufo").setup({
      fold_virt_text_handler = handler,

      provider_selector = function(bufnr, filetype, buftype)

        -- Buffers de UI e tipos que causam problemas — ufo ignora completamente
        local disabled = {
          oil             = true,
          ["neo-tree"]    = true,
          dashboard       = true,
          lazy            = true,
          mason           = true,
          help            = true,
          toggleterm      = true,
          TelescopePrompt = true,
          trouble         = true,
          aerial          = true,
          bib             = true,   -- ← evita erro ao recarregar .bib
          nofile          = true,
          prompt          = true,
          [""]            = false,
        }

        if disabled[filetype] == true then
          return ""
        end

        if disabled[buftype] == true then
          return ""
        end

        -- Proteção: buffer inválido ou sem linhas
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return ""
        end
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        if line_count == 0 then
          return ""
        end

        -- Mapa de providers por filetype
        local ftMap = {
          tex      = { "treesitter", "indent" },
          latex    = { "treesitter", "indent" },
          python   = { "lsp",        "treesitter" },
          rust     = { "lsp",        "treesitter" },
          lua      = { "treesitter", "indent" },
          julia    = { "treesitter", "indent" },
          markdown = { "treesitter", "indent" },
          json     = { "treesitter", "indent" },
          yaml     = { "treesitter", "indent" },
          toml     = { "treesitter", "indent" },
          bash     = { "treesitter", "indent" },
        }

        local providers = ftMap[filetype]

        if providers then
          -- Remove treesitter se o parser não está instalado
          if vim.tbl_contains(providers, "treesitter") and not ts_available(filetype) then
            providers = vim.tbl_filter(function(p)
              return p ~= "treesitter"
            end, providers)
          end
          return #providers > 0 and providers or "indent"
        end

        -- Fallback global: LSP se disponível, senão indent
        local clients = vim.lsp.get_clients({ bufnr = bufnr })
        if #clients > 0 then
          return { "lsp", "indent" }
        end

        return "indent"
      end,

      preview = {
        win_config = {
          border      = "rounded",
          winblend    = 0,
          winhighlight = "Normal:Normal",
          maxheight   = 20,
        },
        mappings = {
          scrollU = "<C-u>",
          scrollD = "<C-d>",
          jumpTop = "gg",
          jumpBot = "G",
        },
      },
    })

    vim.api.nvim_set_hl(0, "UfoFoldedEllipsis", { fg = "#E5C07B" })
  end,
}
