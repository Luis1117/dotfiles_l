return {
  "toppair/peek.nvim",
  build = "deno task --quiet build:fast",
  ft = "markdown",
  config = function()
    local peek = require("peek")
    peek.setup({
      app = "browser",
      theme = "dark",
    })
    
    vim.api.nvim_create_user_command("PeekOpen", function()
      peek.open()
    end, {})
    
    vim.api.nvim_create_user_command("PeekClose", function()
      peek.close()
    end, {})
  end,
}
