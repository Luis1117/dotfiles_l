return {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      surrounds = {
        -- $ para inline math: $texto$
        ["$"] = {
          add = { "$", "$" },
        },
        -- m para \( \) inline math
        ["m"] = {
          add = { "\\(", "\\)" },
        },
        -- M para \[ \] display math
        ["M"] = {
          add = { "\\[", "\\]" },
        },
        -- e para \begin{} \end{} — pede o nome do ambiente
        ["e"] = {
          add = function()
            local env = vim.fn.input("Ambiente: ")
            return {
              { "\\begin{" .. env .. "}" },
              { "\\end{" .. env .. "}" },
            }
          end,
        },
        -- a para align
        ["a"] = {
          add = { "\\begin{align}\n\t", "\n\\end{align}" },
        },
        -- E para equation
        ["E"] = {
          add = { "\\begin{equation}", "\\end{equation}" },
        },
      },
    })
  end,
}
