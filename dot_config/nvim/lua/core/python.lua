-- lua/core/python.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Módulo central Python: detecção de venv, comandos, autocmds.
-- Chamado via require("core.python").setup() dentro do config() de um plugin.
-- NÃO executa nada no topo — apenas define funções.
-- ─────────────────────────────────────────────────────────────────────────────

local M = {}

-- Estado compartilhado entre todos os submódulos
M.python_path = nil

-- ─────────────────────────────────────────────────────────────────────────────
-- Detecta o Python correto para LSP/REPL/Debug (não o provedor pynvim)
-- ─────────────────────────────────────────────────────────────────────────────
function M.find_python_path()
  -- 1. $VIRTUAL_ENV ativo no shell
  if vim.env.VIRTUAL_ENV then
    local p = vim.env.VIRTUAL_ENV .. "/bin/python"
    if vim.fn.executable(p) == 1 then return p end
  end

  -- 2. .venv/venv no diretório do buffer atual
  local buf_dir = vim.fn.expand("%:p:h")
  if buf_dir and buf_dir ~= "" then
    for _, name in ipairs({ ".venv", "venv", ".virtualenv", "env" }) do
      local p = buf_dir .. "/" .. name .. "/bin/python"
      if vim.fn.executable(p) == 1 then return p end
    end
  end

  -- 3. .venv/venv no CWD
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
  local p3 = vim.fn.exepath("python3")
  if p3 ~= "" then return p3 end
  local p = vim.fn.exepath("python")
  if p ~= "" then return p end
  return nil
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Helper de notificação (usa snacks se disponível)
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
-- setup(): chame UMA vez dentro do config() de um plugin
-- ─────────────────────────────────────────────────────────────────────────────
function M.setup()
  -- Provedor fixo do Neovim (pynvim) — NÃO usar venv do projeto
  -- Sobrescreve o valor definido no init.lua principal apenas se necessário
  if not vim.g.python3_host_prog or vim.g.python3_host_prog == "" then
    vim.g.python3_host_prog = "/usr/bin/python3"
  end

  -- Detecção inicial do Python para LSP/REPL
  M.python_path = M.find_python_path()

  if M.python_path then
    vim.defer_fn(function()
      notify("🐍 " .. vim.fn.fnamemodify(M.python_path, ":~"))
    end, 200)
  end

  -- ── Comando: trocar venv manualmente ──────────────────────────────────────
  vim.api.nvim_create_user_command("PythonSetVenv", function(opts)
    local python = opts.args .. "/bin/python"
    if vim.fn.executable(python) == 1 then
      M.python_path = python
      vim.env.VIRTUAL_ENV = opts.args
      notify("Ambiente alterado: " .. opts.args)
      vim.cmd("LspRestart")
    else
      notify("Python não encontrado: " .. python, vim.log.levels.ERROR)
    end
  end, { nargs = 1, complete = "dir", desc = "Definir venv Python" })

  -- ── Comando: mostrar Python em uso ────────────────────────────────────────
  vim.api.nvim_create_user_command("PythonWhich", function()
    local path    = M.python_path or "não definido"
    local version = vim.fn.system(path .. " --version 2>&1"):gsub("\n", "")
    notify(
      "LSP/REPL:  " .. vim.fn.fnamemodify(path, ":~") .. "\n"
      .. "Provider: " .. (vim.g.python3_host_prog or "não definido") .. "\n"
      .. version,
      vim.log.levels.INFO,
      "🐍 Python Atual"
    )
  end, { desc = "Mostrar Python em uso" })

  -- ── Autocmd: re-detectar ao trocar de buffer/diretório ────────────────────
  vim.api.nvim_create_autocmd({ "DirChanged", "BufEnter" }, {
    pattern  = "*.py",
    callback = function()
      local new = M.find_python_path()
      if new and new ~= M.python_path then
        M.python_path = new
      end
    end,
  })
end

return M
