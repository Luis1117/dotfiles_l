return {
  "3rd/image.nvim",
  event = "VeryLazy",

  opts = {
    backend = "kitty",

    max_width = 80,
    max_height = 40,
    max_width_window_percentage = 50,
    max_height_window_percentage = 50,

    editor_only_render_when_focused = true,

    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = true,

        -- Resolve imagens relativas no Obsidian e Markdown normal
        resolve_image_path = function(img_path, base_dir)
          -- Caso seja caminho absoluto
          if string.sub(img_path, 1, 1) == "/" then
            return img_path
          end
          -- Caminho relativo ao arquivo atual (bom para Obsidian)
          return vim.fn.expand(base_dir .. "/" .. img_path)
        end,
      },

      -- Desative logs para performance
      logs = { enabled = false },
    },

    -- Renderiza arquivos de imagem se abertos diretamente
    hijack_file_patterns = {
      "*.png",
      "*.jpg",
      "*.jpeg",
      "*.gif",
      "*.webp",
      "*.svg",
    },
  },

  config = function(_, opts)
    require("image").setup(opts)

    -- Render automático ao abrir Markdown ou "markdown.obsidian"
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "markdown.obsidian" },
      callback = function()
        require("image").refresh()
      end,
    })
  end,
}
