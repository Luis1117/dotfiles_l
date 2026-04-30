-- ~/.config/yazi/init.lua

-- Full Border
require("full-border"):setup({
  type = ui.Border.ROUNDED,
})

-- Git
require("git"):setup()

-- Starship
require("starship"):setup()

-- Bookmarks
require("bookmarks"):setup({
  last_directory = { enable = true, persist = true },
  persist = "all",
  notify = { enable = true, timeout = 1 },
})
