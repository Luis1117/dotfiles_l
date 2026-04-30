-- lua/core/autocmds.lua

-- ─────────────────────────────────────────────────────────────────────────────
-- Recarregar arquivos modificados externamente
-- ─────────────────────────────────────────────────────────────────────────────
vim.opt.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then vim.cmd("checktime") end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.notify("📄 Recarregado: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
  end,
})

-- ─────────────────────────────────────────────────────────────────────────────
-- Highlight de busca: liga ao entrar, desliga ao sair
-- ─────────────────────────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("CmdlineEnter", {
  pattern = "/,?",
  callback = function()
    vim.opt.hlsearch = true
  end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
  pattern = "/,?",
  callback = function()
    vim.opt.hlsearch = false
  end,
})

-- ─────────────────────────────────────────────────────────────────────────────
-- Jupyter: desabilitar formatação automática
-- ─────────────────────────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.ipynb",
  callback = function()
    vim.b.disable_autoformat = true
  end,
})
