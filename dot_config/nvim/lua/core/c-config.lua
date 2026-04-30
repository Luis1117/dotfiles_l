-- ~/.config/nvim/lua/core/c-config.lua

-- ====================================================================
-- TEMPLATES PARA ARQUIVOS C/C++
-- ====================================================================

-- Template para novos arquivos .c
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.c",
  callback = function()
    local lines = {
      "/**",
      " * @file " .. vim.fn.expand("%:t"),
      " * @brief ",
      " * @author " .. (vim.fn.system("git config user.name"):gsub("\n", "") or "Seu Nome"),
      " * @date " .. os.date("%Y-%m-%d"),
      " */",
      "",
      "#include <stdio.h>",
      "#include <stdlib.h>",
      "",
      "int main(int argc, char *argv[]) {",
      "    ",
      "    return EXIT_SUCCESS;",
      "}",
    }
    vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    vim.api.nvim_win_set_cursor(0, { 11, 4 }) -- Cursor dentro do main
  end,
})

-- Template para header files .h
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.h",
  callback = function()
    local filename = vim.fn.expand("%:t"):upper():gsub("%.", "_")
    local lines = {
      "/**",
      " * @file " .. vim.fn.expand("%:t"),
      " * @brief ",
      " * @author " .. (vim.fn.system("git config user.name"):gsub("\n", "") or "Seu Nome"),
      " * @date " .. os.date("%Y-%m-%d"),
      " */",
      "",
      "#ifndef " .. filename,
      "#define " .. filename,
      "",
      "",
      "",
      "#endif // " .. filename,
    }
    vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    vim.api.nvim_win_set_cursor(0, { 10, 0 })
  end,
})
