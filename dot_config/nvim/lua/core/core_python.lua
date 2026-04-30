-- lua/core/python.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Lógica central de detecção de venv, comandos e autocmds globais Python.
-- Carregado via require("core.python") no init.lua ou em plugins/python/init.lua
-- ─────────────────────────────────────────────────────────────────────────────

local M = {}

-- ── Provedor fixo do Neovim (pynvim) ────────────────────────────────────────
-- O provedor remoto precisa de um Python FIXO com pynvim instalado.
-- NÃO usar o venv do projeto aqui.
vim.g.python3_host_prog = "/usr/bin/python3"

-- ── Estado interno ───────────────────────────────────────────────────────────
M.python_path = nil

-- ─────────────────────────────────────────────────────────────────────────────
-- find_python_path(): detecta o Python correto para LSP/REPL/Debug
-- Ordem de prioridade:
--   1. $VIRTUAL_ENV ativo
--   2. .venv/venv no diretório do buffer
--   3. .venv/venv no CWD
--   4. raiz do Git (exceto ~/.config/nvim)
--   5. .python-version (pyenv)
--   6. python3 do sistema
-- ─────────────────────────────────────────────────────────────────────────────
function M.find_python_path()
  -- 1. Variável de ambiente VIRTUAL_ENV
  if vim.env.VIRTUAL_ENV then
    local p = vim.env.VIRTUAL_ENV .. "/bin/python"
    if vim.fn.executable(p) == 1 then return p end
  end

  -- 2. Diretório do buffer atual
  local buf_dir = vim.fn.expand("%:p:h")
  if buf_dir and buf_dir ~= "" then
    for _, name in ipairs({ ".venv", "venv", ".virtualenv", "env" }) do
      local p = buf_dir .. "/" .. name .. "/bin/python"
      if vim.fn.executable(p) == 1 then return p end
    end
  end

  -- 3. CWD
  local cwd = vim.fn.getcwd()
  for _, name in ipairs({ ".venv", "venv", ".virtualenv", "env" }) do
    local p = cwd .. "/" .. name .. "/bin/python"
    if vim.fn.executable(p) == 1 then return p end
  end

  -- 4. Raiz do Git (ignora ~/.config/nvim)
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
  if git_root and vim.fn.isdirectory(git_root) == 1 then
    local nvim_cfg = vim.fn.stdpath("config")
    if git_root ~= nvim_cfg and not git_root:match("%.config/nvim") then
      for _, name in ipairs({ ".venv", "venv" }) do
        local p = git_root .. "/" .. name .. "/bin/python"
        if vim.fn.executable(p) == 1 then return p end
      end
    end
  end

  -- 5. pyenv (.python-version)
  local version_file = cwd .. "/.python-version"
  if vim.fn.filereadable(version_file) == 1 then
    local ver = vim.fn.readfile(version_file)[1]
    if ver then
      local p = vim.fn.expand("~/.pyenv/versions/" .. ver .. "/bin/python")
      if vim.fn.executable(p) == 1 then return p end
    end
  end

  -- 6. Fallback: sistema
  return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3")
      or vim.fn.exepath("python") ~= "" and vim.fn.exepath("python")
      or nil
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Notificação de startup
-- ─────────────────────────────────────────────────────────────────────────────
local function notify(msg, level, title)
  level = level or vim.log.levels.INFO
  if package.loaded["snacks"] then
    require("snacks").notify(msg, { title = title or "Python Env", level = "info" })
  else
    vim.notify(msg, level)
  end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- M.setup(): inicializa detecção + registra comandos + autocmds
-- Chamar uma única vez em plugins/python/init.lua
-- ─────────────────────────────────────────────────────────────────────────────
function M.setup()
  -- Detecção inicial
  M.python_path = M.find_python_path()

  if M.python_path then
    vim.defer_fn(function()
      notify("🐍 " .. vim.fn.fnamemodify(M.python_path, ":~"))
    end, 100)
  end

  -- ── Comando: trocar venv manualmente ──────────────────────────────────────
  vim.api.nvim_create_user_command("PythonSetVenv", function(opts)
    local python = opts.args .. "/bin/python"
    if vim.fn.executable(python) == 1 then
      M.python_path = python
      vim.env.VIRTUAL_ENV = opts.args
      notify("Ambiente alterado para: " .. opts.args)
      vim.cmd("LspRestart")
    else
      notify("Python não encontrado em: " .. python, vim.log.levels.ERROR)
    end
  end, { nargs = 1, complete = "dir", desc = "Definir venv Python manualmente" })

  -- ── Comando: mostrar Python em uso ────────────────────────────────────────
  vim.api.nvim_create_user_command("PythonWhich", function()
    local path    = M.python_path or "não definido"
    local version = vim.fn.system(path .. " --version 2>&1"):gsub("\n", "")
    notify(
      "LSP/REPL: " .. vim.fn.fnamemodify(path, ":~") .. "\n"
      .. "Provider: " .. vim.g.python3_host_prog .. "\n"
      .. version,
      vim.log.levels.INFO,
      "🐍 Python Atual"
    )
  end, { desc = "Mostrar Python em uso" })

  -- ── Autocmd: re-detectar ao trocar de diretório ou abrir .py ──────────────
  vim.api.nvim_create_autocmd({ "DirChanged", "BufEnter" }, {
    pattern = "*.py",
    callback = function()
      local new = M.find_python_path()
      if new and new ~= M.python_path then
        M.python_path = new
      end
    end,
  })
end

return M
