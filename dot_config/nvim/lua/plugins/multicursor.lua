-- lua/plugins/multicursor.lua
return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  event = "VeryLazy",
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()

    -- ================================================================
    -- Adicionar cursores
    -- ================================================================

    -- Adicionar cursor na próxima/anterior ocorrência da palavra
    vim.keymap.set({ "n", "v" }, "<C-n>", function()
      mc.matchAddCursor(1)
    end, { desc = "MC: próxima ocorrência" })

    vim.keymap.set({ "n", "v" }, "<C-p>", function()
      mc.matchAddCursor(-1)
    end, { desc = "MC: ocorrência anterior" })

    -- Adicionar cursor acima/abaixo
    vim.keymap.set({ "n", "v" }, "<C-Up>", function()
      mc.addCursor("k")
    end, { desc = "MC: cursor acima" })

    vim.keymap.set({ "n", "v" }, "<C-Down>", function()
      mc.addCursor("j")
    end, { desc = "MC: cursor abaixo" })

    -- Adicionar cursor na posição atual
    vim.keymap.set("n", "<M-i>", function()
      mc.addCursor(".")
    end, { desc = "MC: cursor aqui" })

    -- Selecionar todas as ocorrências de uma vez
    vim.keymap.set({ "n", "v" }, "<C-a>", function()
      mc.matchAllAddCursors()
    end, { desc = "MC: todas as ocorrências" })

    -- ================================================================
    -- Pular ocorrências (sem adicionar cursor)
    -- ================================================================

    vim.keymap.set({ "n", "v" }, "<C-S-n>", function()
      mc.matchSkipCursor(1)
    end, { desc = "MC: pular próxima" })

    vim.keymap.set({ "n", "v" }, "<C-S-p>", function()
      mc.matchSkipCursor(-1)
    end, { desc = "MC: pular anterior" })

    -- ================================================================
    -- Controle de cursores
    -- ================================================================

    -- Habilitar/desabilitar cursores temporariamente
    vim.keymap.set("n", "<leader>mc", function()
      mc.toggleCursor()
    end, { desc = "MC: toggle cursor" })

    -- Rotacionar cursor principal
    vim.keymap.set({ "n", "v" }, "<C-Left>", function()
      mc.rotateCursors(-1)
    end, { desc = "MC: rotacionar cursor ←" })

    vim.keymap.set({ "n", "v" }, "<C-Right>", function()
      mc.rotateCursors(1)
    end, { desc = "MC: rotacionar cursor →" })

    -- ================================================================
    -- Sair / limpar
    -- ================================================================
    vim.keymap.set({ "n", "v" }, "<Esc>", function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      elseif mc.hasCursors() then
        mc.clearCursors()
      else
        vim.cmd("noh")
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      end
    end, { desc = "MC: limpar cursors / noh" })

    -- ================================================================
    -- Visual com múltiplos cursores
    -- ================================================================

    -- Dividir seleção visual em cursores por linha
    vim.keymap.set("v", "<leader>ms", mc.splitCursors,
      { desc = "MC: split por linha" })

    -- Inserir no início/fim de cada seleção visual
    vim.keymap.set("v", "I", mc.insertVisual, { desc = "MC: insert início" })
    vim.keymap.set("v", "A", mc.appendVisual, { desc = "MC: insert fim" })

    -- Match novo padrão dentro da seleção visual
    vim.keymap.set("v", "M", mc.matchCursors, { desc = "MC: match padrão" })

    -- ================================================================
    -- Highlights
    -- ================================================================
    vim.api.nvim_set_hl(0, "MultiCursorCursor",     { link = "Cursor" })
    vim.api.nvim_set_hl(0, "MultiCursorVisual",     { link = "Visual" })
    vim.api.nvim_set_hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
    vim.api.nvim_set_hl(0, "MultiCursorDisabledVisual", { link = "Visual" })

    -- Contador de cursores na statusline
    local function mc_status()
      if mc.hasCursors() then
        return "󰅕 " .. mc.numCursors()
      end
      return ""
    end

    _G.mc_status = mc_status
  end,
}
