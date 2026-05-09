-- Criar comando :ReloadConfig
vim.api.nvim_create_user_command("ReloadConfig", "source $MYVIMRC", {})

-- ~/.config/nvim/lua/core/commands.lua
vim.api.nvim_create_user_command("TabRename", function(opts)
  require("tabby.feature.tab_name").set(0, opts.args)
end, { nargs = 1 })
