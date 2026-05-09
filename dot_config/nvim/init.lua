-- ~/.config/nvim/init.lua

-- Configurar Python provider ANTES de tudo
vim.g.python3_host_prog = "/usr/bin/python3"
vim.opt.guifont = "JetBrainsMono Nerd Font:h12" 


-- Path do LuaJIT para o magick (image.nvim)
package.path = package.path .. ";" .. vim.fn.expand("~/.luarocks/share/lua/5.1/?.lua")
package.path = package.path .. ";" .. vim.fn.expand("~/.luarocks/share/lua/5.1/?/init.lua")
package.cpath = package.cpath .. ";" .. vim.fn.expand("~/.luarocks/lib/lua/5.1/?.so")

-- nescessario para autosesions:
vim.opt.sessionoptions = {
  "buffers",
  "tabpages",
  "globals",
}

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.c-config")

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
})
require("core.rga")
