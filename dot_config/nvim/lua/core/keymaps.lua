-- ~/.config/nvim/lua/core/keymaps.lua
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- get_project_root é definido no telescope.lua e exportado via _G
-- mas como keymaps.lua carrega antes, definimos um fallback seguro
if not _G.get_project_root then
  _G.get_project_root = function()
    local current_file = vim.fn.expand("%:p:h")
    local nvim_config = vim.fn.expand("~/.config/nvim")
    local git_root = vim.fn.systemlist(
      "git -C " .. vim.fn.shellescape(current_file) .. " rev-parse --show-toplevel"
    )[1]
    if vim.v.shell_error == 0 and git_root and git_root ~= nvim_config then
      return git_root
    end
    return vim.fn.getcwd()
  end
end

-- ================================
-- 💾 Salvar arquivo
-- ================================
map({ "n", "i" }, "<M-s>", function()
  vim.cmd("stopinsert")
  vim.cmd("silent! write")
  vim.notify("💾 Arquivo salvo", vim.log.levels.INFO)
end, { desc = "Salvar arquivo" })

-- ================================
-- 📂 Copiar paths
-- ================================
map("n", ";p", ":let @+ = expand('%:p')<CR>",   { desc = "Copiar path completo" })
map("n", ";d", ":let @+ = expand('%:p:h')<CR>", { desc = "Copiar diretório" })
map("n", ";f", ":let @+ = expand('%:t')<CR>",   { desc = "Copiar nome do arquivo" })

-- ================================
-- 📑 Aerial (Outline/Símbolos)
-- ================================
map("n", ";a", "<cmd>AerialToggle!<CR>",  { desc = "Toggle Aerial (Outline)" })
map("n", ";A", "<cmd>AerialNavToggle<CR>", { desc = "Aerial Navigation" })

-- ================================
-- 🧮 Nvumi (Calculadora em buffer)
-- ================================
map("n", ";n", "<cmd>Nvumi<CR>", { desc = "Calculadora Nvumi" })

-- ================================
-- 🧮 LaTeX (VimTeX)
-- ================================
map("n", "<leader>lc", "<cmd>VimtexCompile<CR>", { desc = "Compilar LaTeX" })
map("n", "<leader>lv", "<cmd>VimtexView<CR>",    { desc = "Abrir PDF" })
map("n", "<leader>lL", "<cmd>VimtexLog<CR>",     { desc = "Ver log VimTeX" })
map("n", "<leader>ls", "<cmd>VimtexStatus<CR>",  { desc = "Status VimTeX" })

-- ================================
-- 🧠 Julia
-- ================================
map("n", "<leader>rj", ":w<CR>:!julia %<CR>", opts)

-- ================================
-- 🪟 Windows split sync
-- ================================
map("n", "<leader>sb", "<cmd>windo set scrollbind!<CR>", { desc = "Toggle scrollbind" })

-- ================================
-- 🧩 Bufferline (abas visuais)
-- ================================
map("n", "<A-n>", ":BufferLineCycleNext<CR>", { desc = "Próximo buffer" })
map("n", "<A-p>", ":BufferLineCyclePrev<CR>", { desc = "Buffer anterior" })
map("n", "<leader>x", ":bdelete<CR>",          { desc = "Fechar buffer atual" })
map("n", "<leader>X", ":%bd|e#|bd#<CR>",       { desc = "Fechar todos exceto o atual" })
map("n", "<A-h>", ":BufferLineMovePrev<CR>",   { desc = "Mover buffer à esquerda" })
map("n", "<A-l>", ":BufferLineMoveNext<CR>",   { desc = "Mover buffer à direita" })

for i = 1, 9 do
  map("n", "<A-" .. i .. ">", "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>",
    { desc = "Ir para buffer " .. i })
end

map("n", "<leader>bo",  ":BufferLineCloseOthers<CR>",  { desc = "Fechar outros buffers" })
map("n", "<leader>br",  ":BufferLineCloseRight<CR>",   { desc = "Fechar buffers à direita" })
map("n", "<leader>bl",  ":BufferLineCloseLeft<CR>",    { desc = "Fechar buffers à esquerda" })
map("n", "<leader>bp",  ":BufferLineTogglePin<CR>",    { desc = "Fixar/desafixar buffer" })
map("n", "<leader>brl", ":edit!<CR>",                  { desc = "Recarregar buffer atual" })
map("n", "<leader><leader>", "<C-^>",                  { desc = "Alternar último buffer" })

-- ================================
-- 📋 Tabela/Markdown
-- ================================
map("n", "<leader>Tm", ":TableModeToggle<CR>", { desc = "Toggle Table Mode" })
map("n", "<leader>Tf", ":TableFormat<CR>",     { desc = "Format Table" })
map("n", "<leader>Tc", ":Tableize<CR>",        { desc = "Convert to Table" })

-- ================================
-- 🖥️ Terminal/Toggle
-- ================================
map("n", "<leader>tt", "<cmd>ToggleTerm<CR>",                       { desc = "Toggle Terminal" })
map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>",       { desc = "Float Terminal" })
map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>",  { desc = "Horizontal Terminal" })
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>",    { desc = "Vertical Terminal" })

-- ================================
-- 🔁 Compilação automática LaTeX ao salvar
-- ================================
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.tex",
  callback = function()
    if vim.fn.exists(":VimtexCompile") == 2 then
      vim.cmd("silent! VimtexCompile")
    end
  end,
})

-- ================================
-- 🔧 C/C++ - Keymaps específicos
-- ================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    local buf_opts = { buffer = true, silent = true }

    map("n", "<leader>cc", function()
      local file = vim.fn.expand("%")
      local output = vim.fn.expand("%:r")
      vim.cmd("!gcc " .. file .. " -o " .. output .. " -Wall -Wextra -g -lm")
      vim.notify("🔨 Compilando: " .. file, vim.log.levels.INFO)
    end, vim.tbl_extend("force", buf_opts, { desc = "[C] Compile file" }))

    map("n", "<leader>ce", function()
      local file = vim.fn.expand("%")
      local output = vim.fn.expand("%:r")
      vim.cmd("!gcc " .. file .. " -o " .. output .. " -Wall -Wextra -g -lm && ./" .. output)
    end, vim.tbl_extend("force", buf_opts, { desc = "[C] Compile & Execute" }))

    map("n", "<leader>cr", function()
      local output = vim.fn.expand("%:r")
      vim.cmd("!./" .. output)
    end, vim.tbl_extend("force", buf_opts, { desc = "[C] Run compiled" }))

    map("n", "<leader>cm", "<cmd>!make<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "[C] Run make" }))

    map("n", "<leader>cM", "<cmd>!make clean && make<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "[C] Clean & make" }))

    map("n", "<leader>cv", function()
      local output = vim.fn.expand("%:r")
      vim.cmd("!valgrind --leak-check=full --show-leak-kinds=all ./" .. output)
      vim.notify("🔍 Analisando memória com Valgrind", vim.log.levels.INFO)
    end, vim.tbl_extend("force", buf_opts, { desc = "[C] Valgrind check" }))

    map("n", "<leader>ca", function()
      local file = vim.fn.expand("%")
      local asm = vim.fn.expand("%:r") .. ".s"
      vim.cmd("!gcc " .. file .. " -S -o " .. asm .. " -Wall -O2")
      vim.notify("⚙️  Assembly gerado: " .. asm, vim.log.levels.INFO)
    end, vim.tbl_extend("force", buf_opts, { desc = "[C] Generate assembly" }))

    map("n", "<leader>cp", function()
      local file = vim.fn.expand("%")
      local prep = vim.fn.expand("%:r") .. ".i"
      vim.cmd("!gcc " .. file .. " -E -o " .. prep)
      vim.notify("📄 Preprocessado: " .. prep, vim.log.levels.INFO)
    end, vim.tbl_extend("force", buf_opts, { desc = "[C] Preprocess" }))

    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = "80"
    vim.opt_local.commentstring = "// %s"
  end,
})
